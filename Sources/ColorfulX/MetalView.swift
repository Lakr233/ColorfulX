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

        var displayLink: CADisplayLink?

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
            let displayLink = CADisplayLink()
            self.displayLink = displayLink

            let link = CADisplayLink(target: self, selector: #selector(displayLinkTik))
            link.add(to: .main, forMode: .common)
            self.displayLink = link
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit {
            displayLink?.invalidate()
            displayLink = nil
        }

        @objc func displayLinkTik() {
            renderIfNeeded()
        }

        func shouldRender() -> Bool {
            true
        }

        func renderIfNeeded() {
            guard shouldRender(),
                  let drawable = metalLayer.nextDrawable(),
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let computeEncoder = commandBuffer.makeComputeCommandEncoder()
            else { return }

            render(withDrawable: drawable, commandBuffer: commandBuffer, computeEncoder: computeEncoder)
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        func render(withDrawable drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer, computeEncoder: MTLComputeCommandEncoder) {
            _ = drawable
            _ = commandBuffer
            _ = computeEncoder
        }

        override public func display(_: CALayer) {
            renderIfNeeded()
        }

        override public func layoutSublayers(of _: CALayer) {
            metalLayer.frame = bounds
            updateDrawableSize()
        }

        private func updateDrawableSize() {
            #if os(visionOS)
                let scaleFactor = 2
            #else
                let scaleFactor = window?.screen.scale ?? 1
            #endif
            metalLayer.drawableSize = CGSize(
                width: bounds.width * scaleFactor,
                height: bounds.height * scaleFactor
            )
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

                CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
                CVDisplayLinkSetOutputCallback(displayLink!, { _, _, _, _, _, userInfo -> CVReturn in
                    let metalView = Unmanaged<MetalView>.fromOpaque(userInfo!).takeUnretainedValue()
                    metalView.renderIfNeeded()
                    return kCVReturnSuccess
                }, Unmanaged.passUnretained(self).toOpaque())
                CVDisplayLinkStart(displayLink!)
            }

            deinit {
                CVDisplayLinkStop(displayLink!)
            }

            @available(*, unavailable)
            public required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            func shouldRender() -> Bool {
                true
            }

            func render(
                withDrawable drawable: CAMetalDrawable,
                commandBuffer: MTLCommandBuffer,
                computeEncoder: MTLComputeCommandEncoder
            ) {
                _ = drawable
                _ = commandBuffer
                _ = computeEncoder
            }

            public func display(_: CALayer) {
                renderIfNeeded()
            }

            func renderIfNeeded() {
                guard shouldRender(),
                      let drawable = metalLayer.nextDrawable(),
                      let commandBuffer = commandQueue.makeCommandBuffer(),
                      let commandEncoder = commandBuffer.makeComputeCommandEncoder()
                else { return }
                render(withDrawable: drawable, commandBuffer: commandBuffer, computeEncoder: commandEncoder)
                commandBuffer.present(drawable)
                commandBuffer.commit()
            }

            public func layoutSublayers(of layer: CALayer) {
                guard layer == metalLayer else { return }
                metalLayer.frame = bounds
                updateDrawableSize()
            }

            private func updateDrawableSize() {
                let scaleFactor = window?.backingScaleFactor ?? 1
                metalLayer.drawableSize = CGSize(
                    width: bounds.width * scaleFactor,
                    height: bounds.height * scaleFactor
                )
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
