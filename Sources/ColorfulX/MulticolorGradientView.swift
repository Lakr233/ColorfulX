//
//  MulticolorGradientView.swift
//  ColorfulX
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import MetalKit

open class MulticolorGradientView: MetalView {
    public var parameters: Parameters = .init() {
        didSet { if oldValue != parameters { needsRender = true } }
    }

    private var needsRender: Bool = false
    private var computePipelineState: MTLComputePipelineState?
    private let lock = NSLock()

    public var renderScale: Double {
        get { metalLink?.scaleFactor ?? 1 }
        set { metalLink?.scaleFactor = newValue }
    }

    override public init() {
        super.init()

        if let device = metalLink?.metalDevice,
           let library = try? device.createColorfulLibrary(),
           let computeProgram = library.makeFunction(name: "blend_colors"),
           let pipelineState = try? device.makeComputePipelineState(function: computeProgram)
        {
            computePipelineState = pipelineState
        } else {
            computePipelineState = nil
        }
    }

    override func vsync() {
        super.vsync()
        renderIfNeeded()
    }

    func renderIfNeeded() {
        guard needsRender else { return }
        defer { needsRender = false }
        if Thread.isMainThread {
            render()
        } else {
            DispatchQueue.main.sync {
                render()
            }
        }
    }

    func render() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0)

        let lock = lock
        guard lock.try() else {
            CATransaction.commit()
            return
        }

        guard let metalLink,
              let computePipelineState,
              let drawable = metalLink.metalLayer.nextDrawable(),
              let commandBuffer = metalLink.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        else {
            lock.unlock()
            CATransaction.commit()
            return
        }
        commandBuffer.addCompletedHandler { _ in
            lock.unlock()
        }

        var shaderPoints: [(simd_float2, simd_float4)] = Array(
            repeating: (
                simd_float2(0.0, 0.0),
                simd_float4(0.0, 0.0, 0.0, 0.0)
            ),
            count: Uniforms.COLOR_SLOT
        )

        let parms = parameters

        for i in 0 ..< parms.points.count {
            let point = parms.points[i]
            let color = point.color.color(in: .lab)
            shaderPoints[i] = (
                simd_float2(Float(point.position.x), Float(point.position.y)),
                simd_float4(color.v)
            )
        }

        var uniforms = Uniforms(
            pointCount: simd_int1(parms.points.count),
            bias: simd_float1(parms.bias),
            power: simd_float1(parms.power),
            noise: simd_float1(parms.noise),

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

        let metalLayer = metalLink.metalLayer
        let originalValue = metalLayer.presentsWithTransaction
        metalLayer.presentsWithTransaction = true
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()
        drawable.present()
        metalLayer.presentsWithTransaction = originalValue

        CATransaction.commit()
    }
}
