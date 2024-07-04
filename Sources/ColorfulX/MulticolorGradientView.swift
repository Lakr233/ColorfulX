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
              let computeProgram = library.makeFunction(name: colorSpace.metalRenderFunctionName)
        else { fatalError("Metal program filed to compile") }

        let pipelineDescriptor = MTLComputePipelineDescriptor()
        pipelineDescriptor.computeFunction = computeProgram

        guard let computePipelineState = try? device.makeComputePipelineState(descriptor: pipelineDescriptor, options: [])
        else { fatalError("Metal program filed to compile") }

        self.computePipelineState = computePipelineState.0
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
            let color = point.color.color(in: .rgb)
            shaderPoints[i] = (
                simd_float2(Float(point.position.x), Float(point.position.y)),
                simd_float4(
                    Float(color.rgba.r / 255),
                    Float(color.rgba.g / 255),
                    Float(color.rgba.b / 255),
                    Float(color.rgba.a)
                )
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
//            point8: shaderPoints[8].0,
//            point9: shaderPoints[9].0,
//            point10: shaderPoints[10].0,
//            point11: shaderPoints[11].0,
//            point12: shaderPoints[12].0,
//            point13: shaderPoints[13].0,
//            point14: shaderPoints[14].0,
//            point15: shaderPoints[15].0,
//            point16: shaderPoints[16].0,
//            point17: shaderPoints[17].0,
//            point18: shaderPoints[18].0,
//            point19: shaderPoints[19].0,
//            point20: shaderPoints[20].0,
//            point21: shaderPoints[21].0,
//            point22: shaderPoints[22].0,
//            point23: shaderPoints[23].0,
//            point24: shaderPoints[24].0,
//            point25: shaderPoints[25].0,
//            point26: shaderPoints[26].0,
//            point27: shaderPoints[27].0,
//            point28: shaderPoints[28].0,
//            point29: shaderPoints[29].0,
//            point30: shaderPoints[20].0,
//            point31: shaderPoints[31].0,

            color0: shaderPoints[0].1,
            color1: shaderPoints[1].1,
            color2: shaderPoints[2].1,
            color3: shaderPoints[3].1,
            color4: shaderPoints[4].1,
            color5: shaderPoints[5].1,
            color6: shaderPoints[6].1,
            color7: shaderPoints[7].1 // ,
//            color8:shaderPoints[8].1,
//            color9:shaderPoints[9].1,
//            color10:shaderPoints[10].1,
//            color11:shaderPoints[11].1,
//            color12:shaderPoints[12].1,
//            color13:shaderPoints[13].1,
//            color14:shaderPoints[14].1,
//            color15:shaderPoints[15].1,
//            color16:shaderPoints[16].1,
//            color17:shaderPoints[17].1,
//            color18:shaderPoints[18].1,
//            color19:shaderPoints[19].1,
//            color20:shaderPoints[20].1,
//            color21:shaderPoints[21].1,
//            color22:shaderPoints[22].1,
//            color23:shaderPoints[23].1,
//            color24:shaderPoints[24].1,
//            color25:shaderPoints[25].1,
//            color26:shaderPoints[26].1,
//            color27:shaderPoints[27].1,
//            color28:shaderPoints[28].1,
//            color29:shaderPoints[29].1,
//            color30:shaderPoints[20].1,
//            color31:shaderPoints[31].1
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
