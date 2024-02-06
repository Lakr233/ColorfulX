//
//  MetalView.swift
//
//
//  Created by QAQ on 2023/12/4.
//

import Foundation
import MetalKit

#if canImport(UIKit)
    import UIKit

    open class MetalView: UIView {
        private let delayedVsync = DispatchQueue(label: "wiki.qaq.vsync")

        let metalDevice: MTLDevice
        let metalLayer: CAMetalLayer
        let commandQueue: MTLCommandQueue

        private weak var mDisplayLink: CADisplayLink?
        private var hasParentWindow: Bool = false
        private var hasActiveScene: Bool = true

        public var isPaused: Bool = false {
            didSet {
                updateDisplayLink()
            }
        }

        init() {
            guard let device = MTLCreateSystemDefaultDevice(),
                  let commandQueue = device.makeCommandQueue()
            else {
                fatalError("Metal is not supported on this device")
            }
            metalDevice = device
            self.commandQueue = commandQueue

            let metalLayer = CAMetalLayer()
            metalLayer.device = metalDevice
            metalLayer.pixelFormat = .bgra8Unorm
            metalLayer.framebufferOnly = false
            self.metalLayer = metalLayer

            super.init(frame: .zero)

            layer.addSublayer(metalLayer)
            backgroundColor = .clear

            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationwillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        }

        @objc
        func applicationDidBecomeActive(_: Notification) {
            hasActiveScene = true
        }

        @objc
        func applicationwillResignActive(_: Notification) {
            hasActiveScene = false
        }

        deinit {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override open func willMove(toWindow newWindow: UIWindow?) {
            super.willMove(toWindow: newWindow)
            hasParentWindow = (newWindow != nil)
            updateDisplayLink()
        }

        private func updateDisplayLink() {
            if hasParentWindow, !isPaused, hasActiveScene {
                if mDisplayLink == nil {
                    let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCall(_:)))
                    displayLink.add(to: .main, forMode: .common)
                    mDisplayLink = displayLink
                }
            } else {
                mDisplayLink?.invalidate()
                mDisplayLink = nil
            }
        }

        @objc func displayLinkCall(_: CADisplayLink) {
            delayedVsync.async { [weak self] in
                self?.vsync()
            }
        }

        func vsync() {}

        override public func layoutSublayers(of _: CALayer) {
            // 15.79ms for a 1290x2796 image on iPhone 15 Pro Max
            // native scaleFactor will case a performance issue
            // so we downscale the image to 1x
            let scaleFactor: CGFloat = 1.0
            metalLayer.frame = bounds
            var width = bounds.width * scaleFactor
            var height = bounds.height * scaleFactor
            assert(width <= 8192 && height <= 8192, "rendering over 8k is not supported")
            if width <= 0 { width = 1 }
            if height <= 0 { height = 1 }
            if width > 8192 { width = 8192 }
            if height > 8192 { height = 8192 }
            metalLayer.drawableSize = CGSize(width: width, height: height)
        }
    }
#else
    #if canImport(AppKit)
        import AppKit

        open class MetalView: NSView, CALayerDelegate {
            private let delayedVsync = DispatchQueue(label: "wiki.qaq.vsync")

            let metalDevice: MTLDevice
            let metalLayer: CAMetalLayer
            let commandQueue: MTLCommandQueue

            var displayLink: CVDisplayLink?

            init() {
                guard let device = MTLCreateSystemDefaultDevice(),
                      let commandQueue = device.makeCommandQueue()
                else {
                    fatalError("Metal is not supported on this device")
                }
                metalDevice = device
                self.commandQueue = commandQueue

                let metalLayer = CAMetalLayer()
                metalLayer.device = metalDevice
                metalLayer.pixelFormat = .bgra8Unorm
                metalLayer.framebufferOnly = false
                self.metalLayer = metalLayer

                super.init(frame: .zero)

                wantsLayer = true
                layer = metalLayer
                metalLayer.delegate = self

                CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
                if let displayLink = displayLink {
                    CVDisplayLinkSetOutputCallback(displayLink, { _, _, _, _, _, object -> CVReturn in
                        guard let object = object else { return kCVReturnError }
                        let me = Unmanaged<MetalView>.fromOpaque(object).takeUnretainedValue()
                        me.delayedVsync.async { me.vsync() }
                        return kCVReturnSuccess
                    }, Unmanaged.passUnretained(self).toOpaque())
                    CVDisplayLinkStart(displayLink)
                } else { assertionFailure() }
            }

            @available(*, unavailable)
            public required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            deinit {
                if let displayLink = displayLink { CVDisplayLinkStop(displayLink) }
                displayLink = nil
            }

            func vsync() {}

            public func layoutSublayers(of layer: CALayer) {
                guard layer == metalLayer else { return }
                metalLayer.frame = bounds
                let scaleFactor = 1.0
                var width = bounds.width * scaleFactor
                var height = bounds.height * scaleFactor
                assert(width <= 8192 && height <= 8192, "rendering over 8k is not supported")
                if width <= 0 { width = 1 }
                if height <= 0 { height = 1 }
                if width > 8192 { width = 8192 }
                if height > 8192 { height = 8192 }
                metalLayer.drawableSize = CGSize(width: width, height: height)
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
