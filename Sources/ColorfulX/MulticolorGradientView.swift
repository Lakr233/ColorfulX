//
//  MulticolorGradientView.swift
//  ColorfulX
//
//  Created by QAQ on 2023/12/3.
//

import MetalKit

public class MulticolorGradientView: MTKView, MTKViewDelegate {
    public var parameters: Parameters = .init()

    private var commandQueue: MTLCommandQueue
    private var computePipelineState: MTLComputePipelineState

    public init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = try? device.makeDefaultLibrary(bundle: Bundle.module),
              let computeProgram = library.makeFunction(name: "gradient"),
              let computePipelineState = try? device.makeComputePipelineState(function: computeProgram)
        else {
            fatalError("Metal is not supported on this device")
        }
        self.commandQueue = commandQueue
        self.computePipelineState = computePipelineState

        super.init(frame: .zero, device: device)

        framebufferOnly = false
        isPaused = false
        delegate = self
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) { fatalError() }

    public func draw(in _: MTKView) {
        guard let drawable = currentDrawable else { return }
        draw(with: parameters, in: drawable)
    }

    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}

    public func draw(with parameters: Parameters, in drawable: CAMetalDrawable) {
        var shaderPoints: [(simd_float2, simd_float3)] = Array(
            repeating: (
                simd_float2(0.0, 0.0),
                simd_float3(0.0, 0.0, 0.0)
            ),
            count: 8
        )

        for i in 0 ..< parameters.points.count {
            let point = parameters.points[i]
            shaderPoints[i] = (
                simd_float2(Float(point.position.x), Float(point.position.y)),
                simd_float3(point.color.r, point.color.g, point.color.b)
            )
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

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        computeEncoder.setComputePipelineState(computePipelineState)
        computeEncoder.setBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        computeEncoder.setTexture(drawable.texture, index: 4)
        let threadGroupCount = MTLSizeMake(1, 1, 1)
        let threadGroups = MTLSizeMake(
            drawable.texture.width / threadGroupCount.width,
            drawable.texture.height / threadGroupCount.height,
            1
        )
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        computeEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
