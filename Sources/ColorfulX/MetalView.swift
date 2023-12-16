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
        let metalDevice: MTLDevice
        let metalLayer: CAMetalLayer
        let commandQueue: MTLCommandQueue

        var displayLink: CADisplayLink!

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

            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCall))
            displayLink.add(to: .main, forMode: .common)
            
            backgroundColor = .clear
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit { displayLink.invalidate() }

        @objc func displayLinkCall() { vsync() }

        func vsync() {}

        override public func layoutSublayers(of _: CALayer) {
            #if os(visionOS)
                let scaleFactor: CGFloat = 2
            #else
                let scaleFactor = window?.screen.scale ?? 1
            #endif
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
            }

            @available(*, unavailable)
            public required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            deinit {
                if let displayLink { CVDisplayLinkStop(displayLink) }
                displayLink = nil
            }

            override open func viewDidMoveToWindow() {
                super.viewDidMoveToWindow()

                if let displayLink { CVDisplayLinkStop(displayLink) }
                displayLink = nil

                guard let screen = window?.screen else { return }
                guard let displayID = screen.deviceDescription[
                    .init(rawValue: "NSScreenNumber")
                ] as? Int else {
                    assertionFailure()
                    return
                }

                CVDisplayLinkCreateWithCGDisplay(CGDirectDisplayID(displayID), &displayLink)
                guard let displayLink else {
                    assertionFailure()
                    return
                }

                CVDisplayLinkSetOutputCallback(displayLink, { _, _, _, _, _, object -> CVReturn in
                    guard let object else { return kCVReturnError }
                    let me = Unmanaged<MetalView>.fromOpaque(object).takeUnretainedValue()
                    me.vsync()
                    return kCVReturnSuccess
                }, Unmanaged.passUnretained(self).toOpaque())
                CVDisplayLinkStart(displayLink)
            }

            func vsync() {}

            public func layoutSublayers(of layer: CALayer) {
                guard layer == metalLayer else { return }
                metalLayer.frame = bounds
                let scaleFactor = window?.backingScaleFactor ?? 1
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
