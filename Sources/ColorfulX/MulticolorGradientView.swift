//
//  MulticolorGradientView.swift
//  ColorfulX
//
//  Created by QAQ on 2023/12/3.
//

import MetalKit

public class MulticolorGradientView: MetalView {
    public var parameters: Parameters = .init() {
        didSet { if oldValue != parameters { needsRender = true } }
    }

    private var needsRender: Bool = false
    private var computePipelineState: MTLComputePipelineState!

    override public init() {
        super.init()

        let device = metalDevice
        guard let library = try? device.makeDefaultLibrary(bundle: Bundle.module),
              let computeProgram = library.makeFunction(name: "gradient"),
              let computePipelineState = try? device.makeComputePipelineState(function: computeProgram)
        else { fatalError("Metal program filed to compile") }
        self.computePipelineState = computePipelineState
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        needsRender = true
    }

    override func vsync() {
        super.vsync()

        guard let drawable = metalLayer.nextDrawable(),
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }

        defer { needsRender = false }

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

        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.setBytes(&uniforms, length: MemoryLayout<Uniforms>.size, index: 0)
        commandEncoder.setTexture(drawable.texture, index: 4)
        let threadGroupCount = MTLSizeMake(1, 1, 1)
        let threadGroups = MTLSizeMake(
            drawable.texture.width / threadGroupCount.width,
            drawable.texture.height / threadGroupCount.height,
            1
        )

        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()
        drawable.present()
    }
}
