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
    private var computePipelineState: MTLComputePipelineState!
    private let lock = NSLock()

    public private(set) var currentDrawable: CAMetalDrawable? = nil
    public var currentTexture: MTLTexture? { currentDrawable?.texture }
    public var captureImage: CGImage? { currentTexture?.capture() }

    public let colorSpace: ColorSpace
    public init(colorSpace: ColorSpace = .lab) {
        self.colorSpace = colorSpace

        super.init()

        let device = metalDevice
        guard let library = try? device.createColorfulLibrary(),
              let computeProgram = library.makeFunction(name: colorSpace.metalRenderFunctionName),
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

        guard lock.try() else { return }
        defer { lock.unlock() }

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

        let parms = parameters

        for i in 0 ..< parms.points.count {
            let point = parms.points[i]
            shaderPoints[i] = (
                simd_float2(Float(point.position.x), Float(point.position.y)),
                simd_float3(Float(point.color.rgb.r), Float(point.color.rgb.g), Float(point.color.rgb.b))
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
        commandBuffer.commit()
        commandBuffer.waitUntilScheduled()

        if Thread.isMainThread {
            drawable.present()
            currentDrawable = drawable
            commandBuffer.waitUntilCompleted()
        } else {
            DispatchQueue.main.asyncAndWait(execute: DispatchWorkItem {
                drawable.present()
                self.currentDrawable = drawable
            })
            commandBuffer.waitUntilCompleted()
        }
    }
}

private extension MTLTexture {
    func capture() -> CGImage? {
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let rowBytes = width * bytesPerPixel

        let buffer = malloc(width * height * bytesPerPixel)
        guard let buffer else { return nil }
        defer { free(buffer) }

        getBytes(
            buffer,
            bytesPerRow: width * bytesPerPixel,
            from: MTLRegionMake2D(0, 0, width, height),
            mipmapLevel: 0
        )

        let rawBitmapInfo = 0
            | CGImageAlphaInfo.noneSkipFirst.rawValue
            | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)

        let selftureSize = width * height * bytesPerPixel
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { _, _, _ in
        }
        guard let provider = CGDataProvider(
            dataInfo: nil,
            data: buffer,
            size: selftureSize,
            releaseData: releaseMaskImagePixelData
        ) else { return nil }

        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerComponent * bytesPerPixel,
            bytesPerRow: rowBytes,
            space: colorspace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
    }
}

extension ColorSpace {
    var metalRenderFunctionName: String {
        switch self {
        case .lch: return "gradientWithLCH"
        case .lab: return "gradientWithLAB"
        case .xyz: return "gradientWithXYZ"
        case .rgb: return "gradientWithRGB"
        }
    }
}
