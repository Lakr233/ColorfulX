//
//  MulticolorGradientViewController.swift
//
//
//  Created by Arthur Guibert on 31/10/2022.
//

import MetalKit
import SwiftUI

private struct Uniforms {
    let pointCount: simd_int1

    let bias: simd_float1
    let power: simd_float1
    let noise: simd_float1

    let point0: simd_float2
    let point1: simd_float2
    let point2: simd_float2
    let point3: simd_float2
    let point4: simd_float2
    let point5: simd_float2
    let point6: simd_float2
    let point7: simd_float2

    let color0: simd_float3
    let color1: simd_float3
    let color2: simd_float3
    let color3: simd_float3
    let color4: simd_float3
    let color5: simd_float3
    let color6: simd_float3
    let color7: simd_float3
}

struct GradientParameters {
    var points: [ColorStop] = []
    var bias: Float = 0.001
    var power: Float = 2
    var noise: Float = 2.0
}

#if canImport(UIKit)
    public class MulticolorGradientViewController: UIViewController, MTKViewDelegate {
        private var mtkView: MTKView
        private var computePipelineState: MTLComputePipelineState?
        private var commandQueue: MTLCommandQueue

        private var colorInterpolation: MulticolorGradient.ColorInterpolation = .rgb
        private var current: GradientParameters = .init()
        private var nextGradient: GradientParameters?

        private var duration: TimeInterval?
        private var elapsed: TimeInterval = 0.0
        private var timeDirection: Double = 1
        private var repeatForever: Bool = false
        private var previousFrameTime: Date = .init()

        init() {
            let renderView = MTKView()
            renderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
                fatalError("Metal is not supported on this device")
            }

            renderView.device = defaultDevice
            renderView.preferredFramesPerSecond = 60
            renderView.device = defaultDevice
            renderView.framebufferOnly = false
            renderView.isPaused = false

            mtkView = renderView
            commandQueue = defaultDevice.makeCommandQueue()!

            super.init(nibName: nil, bundle: nil)

            view.addSubview(renderView)
            renderView.frame = view.bounds
            renderView.delegate = self

            if setComputePipeline(device: defaultDevice) == nil {
                fatalError("default fragment shader has problem compiling")
            }
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

        public func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            let timeStep = Date().timeIntervalSince(previousFrameTime)
            previousFrameTime = Date()
            updateAnimationIfNeeded(timeStep)
            draw(with: computeParameters(), in: drawable)
        }
    }
#else
    #if canImport(AppKit)
        public class MulticolorGradientViewController: NSViewController, MTKViewDelegate {
            private var mtkView: MTKView
            private var computePipelineState: MTLComputePipelineState?
            private var commandQueue: MTLCommandQueue

            private var colorInterpolation: MulticolorGradient.ColorInterpolation = .rgb
            private var current: GradientParameters = .init()
            private var nextGradient: GradientParameters?

            private var duration: TimeInterval?
            private var elapsed: TimeInterval = 0.0
            private var timeDirection: Double = 1
            private var repeatForever: Bool = false
            private var previousFrameTime: Date = .init()

            init() {
                let renderView = MTKView()
                renderView.autoresizingMask = [.width, .height]
                guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
                    fatalError("Metal is not supported on this device")
                }

                renderView.device = defaultDevice
                renderView.preferredFramesPerSecond = 60
                renderView.framebufferOnly = false
                renderView.isPaused = false

                mtkView = renderView
                commandQueue = defaultDevice.makeCommandQueue()!

                super.init(nibName: nil, bundle: nil)

                view.addSubview(renderView)
                renderView.frame = view.bounds
                renderView.delegate = self

                if setComputePipeline(device: defaultDevice) == nil {
                    fatalError("default fragment shader has problem compiling")
                }
            }

            @available(*, unavailable)
            required init?(coder _: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

            public func draw(in view: MTKView) {
                guard let drawable = view.currentDrawable else { return }
                let timeStep = Date().timeIntervalSince(previousFrameTime)
                previousFrameTime = Date()
                updateAnimationIfNeeded(timeStep)
                draw(with: computeParameters(), in: drawable)
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif

extension MulticolorGradientViewController {
    func setComputePipeline(device: MTLDevice) -> MTLComputePipelineState? {
        if let computeProgram = loadShaders(device: device) {
            computePipelineState = try? device.makeComputePipelineState(function: computeProgram)
            return computePipelineState
        }

        return nil
    }

    func loadShaders(device: MTLDevice) -> MTLFunction? {
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module)
        else { fatalError("unable to create default library") }
        return library.makeFunction(name: "gradient")
    }

    func animate(to parameters: GradientParameters, animation: MirrorAnimation) {
        current = computeParameters()
        nextGradient = parameters
        duration = animation.duration
        timeDirection = 1.0
        repeatForever = animation.repeatAnimation != nil && animation.repeatAnimation!.count == nil
        elapsed = -animation.delay
        resumeAnimation()
    }

    func update(with parameters: GradientParameters, colorInterpolation: MulticolorGradient.ColorInterpolation = .rgb) {
        current.points = parameters.points
        current.bias = parameters.bias
        current.power = parameters.power
        current.noise = parameters.noise
        self.colorInterpolation = colorInterpolation
        resumeAnimation()
    }

    func pauseAnimation() {
        mtkView.isPaused = true
    }

    func resumeAnimation() {
        mtkView.isPaused = false
        previousFrameTime = Date()
    }

    func draw(with parameters: GradientParameters, in drawable: CAMetalDrawable) {
        var shaderPoints: [(simd_float2, simd_float3)] = Array(
            repeating: (
                simd_float2(0.0, 0.0),
                simd_float3(0.0, 0.0, 0.0)
            ),
            count: 8
        )

        for i in 0 ..< parameters.points.count {
            let point = parameters.points[i]
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            CoreColor(point.color).getRed(&r, green: &g, blue: &b, alpha: nil)

            shaderPoints[i] = (simd_float2(Float(point.position.x), Float(point.position.y)), simd_float3(Float(r), Float(g), Float(b)))
        }

        var uniforms = Uniforms(
            pointCount: simd_int1(parameters.points.count),
            bias: parameters.bias,
            power: parameters.power,
            noise: parameters.noise,
            point0: shaderPoints[0].0,
            point1: shaderPoints[1].0,
            point2: shaderPoints[2].0,
            point3: shaderPoints[3].0,
            point4: shaderPoints[4].0,
            point5: shaderPoints[5].0,
            point6: shaderPoints[6].0,
            point7: shaderPoints[7].0,
            color0: shaderPoints[0].1,
            color1: shaderPoints[1].1,
            color2: shaderPoints[2].1,
            color3: shaderPoints[3].1,
            color4: shaderPoints[4].1,
            color5: shaderPoints[5].1,
            color6: shaderPoints[6].1,
            color7: shaderPoints[7].1
        )

        guard let computePipelineState else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeEncoder?.setComputePipelineState(computePipelineState)
        computeEncoder?.setBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        computeEncoder?.setTexture(drawable.texture, index: 4)

        let threadGroupCount = MTLSizeMake(1, 1, 1)
        let threadGroups = MTLSizeMake(
            drawable.texture.width / threadGroupCount.width,
            drawable.texture.height / threadGroupCount.height,
            1
        )
        computeEncoder?.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)

        computeEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}

private extension MulticolorGradientViewController {
    func updateAnimationIfNeeded(_ timeStep: TimeInterval) {
        guard let duration, let nextGradient else {
            pauseAnimation()
            return
        }

        elapsed += timeStep * timeDirection

        if elapsed < 0 {
            elapsed = 0
            timeDirection = 1.0
        }

        if elapsed > duration {
            if repeatForever {
                timeDirection = -1.0
                elapsed = duration
            } else {
                current = nextGradient
                self.duration = nil
                self.nextGradient = nil
            }
        }
    }

    func computeParameters() -> GradientParameters {
        if let duration, let nextGradient, elapsed >= 0 {
            guard nextGradient.points.count == current.points.count else {
                return nextGradient
            }

            var parameters: GradientParameters = .init()
            let mappedTime = elapsed / duration
            parameters.power = current.power + (nextGradient.power - current.power) * Float(mappedTime)
            parameters.bias = current.bias + (nextGradient.bias - current.bias) * Float(mappedTime)
            parameters.noise = current.noise + (nextGradient.noise - current.noise) * Float(mappedTime)

            for i in 0 ..< nextGradient.points.count {
                let position = current.points[i].position.lerp(to: nextGradient.points[i].position, t: mappedTime)
                let p = if colorInterpolation == .rgb {
                    ColorStop(
                        position: position,
                        color: current.points[i].color.lerp(
                            to: nextGradient.points[i].color,
                            t: mappedTime
                        )
                    )
                } else {
                    ColorStop(
                        position: position,
                        color: current.points[i].color.lerpHSB(
                            to: nextGradient.points[i].color,
                            t: mappedTime
                        )
                    )
                }
                parameters.points.append(p)
            }

            return parameters
        } else {
            return current
        }
    }
}

private extension UnitPoint {
    func lerp(to: UnitPoint, t: Double) -> UnitPoint {
        UnitPoint(x: x + (to.x - x) * t, y: y + (to.y - y) * t)
    }
}
