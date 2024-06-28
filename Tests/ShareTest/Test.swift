import ColorfulX
import MetalKit
import XCTest

class ColorConversionTests: XCTestCase {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!

    override func setUp() {
        super.setUp()
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        library = try! device.createColorfulLibrary()
    }

    typealias ColorSIMD = SIMD3<Float>

    private func computeColorWith(_ colorInput: ColorSIMD, program: MTLComputePipelineState) -> ColorSIMD {
        var colorSIMD = colorInput
        let buffer = device.makeBuffer(bytes: &colorSIMD, length: MemoryLayout<SIMD3<Float>>.stride, options: [])!
        defer { buffer.setPurgeableState(.empty) }

        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(program)
        commandEncoder.setBuffer(buffer, offset: 0, index: 0)

        let outputBuffer = device.makeBuffer(length: MemoryLayout<ColorSIMD>.stride, options: [])!
        commandEncoder.setBuffer(outputBuffer, offset: 0, index: 1)

        let threadGroupCount = MTLSize(width: 1, height: 1, depth: 1)
        let threadGroups = MTLSize(width: 1, height: 1, depth: 1)
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        commandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        let contents = outputBuffer.contents().bindMemory(to: ColorSIMD.self, capacity: 1)
        return contents.pointee
    }

    enum ColorProgram: String {
        case computeColorFromRGBtoXYZ
        case computeColorFromXYZtoLAB
        case computeColorFromLABtoLCH
        case computeColorFromRGBtoLCH
        case computeColorFromLCHtoLAB
        case computeColorFromLABtoXYZ
        case computeColorFromXYZtoRGB
    }

    private func computeColorWith(_ colorInput: ColorSIMD, program: ColorProgram) -> ColorSIMD {
        let functionCallRGB2LCH = library.makeFunction(name: program.rawValue)!
        let computePipelineStateForFunctionRGB2LCH = try! device.makeComputePipelineState(function: functionCallRGB2LCH)
        return computeColorWith(colorInput, program: computePipelineStateForFunctionRGB2LCH)
    }

    private func convertFromRGB2XYZ(_ rgbColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(rgbColor, program: .computeColorFromRGBtoXYZ)
    }

    private func convertFromXYZ2LAB(_ xyzColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(xyzColor, program: .computeColorFromXYZtoLAB)
    }

    private func convertFromLAB2LCH(_ labColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(labColor, program: .computeColorFromLABtoLCH)
    }

    private func convertFromRGB2LCH(_ rgbColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(rgbColor, program: .computeColorFromRGBtoLCH)
    }

    private func convertFromLCH2LAB(_ lchColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(lchColor, program: .computeColorFromLCHtoLAB)
    }

    private func convertFromLAB2XYZ(_ labColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(labColor, program: .computeColorFromLABtoXYZ)
    }

    private func convertFromXYZ2RGB(_ xyzColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(xyzColor, program: .computeColorFromXYZtoRGB)
    }

    private func convertFromLCH2RGB(_ lchColor: ColorSIMD) -> ColorSIMD {
        computeColorWith(lchColor, program: .computeColorFromLCHtoLAB)
    }

    func testColorConversion() {
        var colors = [SIMD3<Float>]()

        for preset in ColorfulX.ColorfulPreset.allCases {
            let input = preset.colors
                .map { RGBColor(CoreColor($0)) }
                .map { SIMD3<Float>($0.r, $0.g, $0.b) }
            colors.append(contentsOf: input)
        }

        colors.insert(SIMD3<Float>(0.9529412, 0.9529412, 0.9529412), at: 0)

        for (idx, color) in colors.enumerated() {
            var output = [String]()
            output.append("[*] test case \(idx)")

            let input = ColorfulX.RGBColor(r: color.x, g: color.y, b: color.z)
            output.append("  > input:    r: \(color.x.pretty), g: \(color.y.pretty), b: \(color.z.pretty)")

            let mXYZ = convertFromRGB2XYZ(color)
            let eXYZ = input.xyz
            output.append("  === RGB to XYZ ===")
            output.append("  > expect:   x: \(eXYZ.x.pretty), y: \(eXYZ.y.pretty), z: \(eXYZ.z.pretty)")
            output.append("  > shader:   x: \(mXYZ.x.pretty), y: \(mXYZ.y.pretty), z: \(mXYZ.z.pretty)")

            XCTAssertEqual(mXYZ.x, eXYZ.x, accuracy: 1)
            XCTAssertEqual(mXYZ.y, eXYZ.y, accuracy: 1)
            XCTAssertEqual(mXYZ.z, eXYZ.z, accuracy: 1)

            let mLAB = convertFromXYZ2LAB(mXYZ)
            let eLAB = input.lab
            output.append("  === XYZ to LAB ===")
            output.append("  > expect:   l: \(eLAB.l.pretty), a: \(eLAB.a.pretty), b: \(eLAB.b.pretty)")
            output.append("  > shader:   l: \(mLAB.x.pretty), a: \(mLAB.y.pretty), b: \(mLAB.z.pretty)")

            XCTAssertEqual(mLAB.x, eLAB.l, accuracy: 1)
            XCTAssertEqual(mLAB.y, eLAB.a, accuracy: 1)
            XCTAssertEqual(mLAB.z, eLAB.b, accuracy: 1)

            let mLCH = convertFromLAB2LCH(mLAB)
            let eLCH = input.lch
            output.append("  === LAB to LCH ===")
            output.append("  > expect:   l: \(eLCH.l.pretty), c: \(eLCH.c.pretty), h: \(eLCH.h.pretty)")
            output.append("  > shader:   l: \(mLCH.x.pretty), c: \(mLCH.y.pretty), h: \(mLCH.z.pretty)")

            XCTAssertEqual(mLCH.x, eLCH.l, accuracy: 1)
            XCTAssertEqual(mLCH.y, eLCH.c, accuracy: 1)
            XCTAssertEqual(mLCH.z, eLCH.h, accuracy: 1)

            let dLCH = convertFromRGB2LCH(color)
            output.append("  === RGB to LCH ===")
            output.append("  > expect:   l: \(eLCH.l.pretty), c: \(eLCH.c.pretty), h: \(eLCH.h.pretty)")
            output.append("  > direct:   l: \(dLCH.x.pretty), c: \(dLCH.y.pretty), h: \(dLCH.z.pretty)")

            XCTAssertEqual(dLCH.x, eLCH.l, accuracy: 1)
            XCTAssertEqual(dLCH.y, eLCH.c, accuracy: 1)
            XCTAssertEqual(dLCH.z, eLCH.h, accuracy: 1)
            
            // now convert back
            let mLAB2 = convertFromLCH2LAB(mLCH)
            output.append("  === LCH to LAB ===")
            output.append("  > expect:   l: \(eLAB.l.pretty), a: \(eLAB.a.pretty), b: \(eLAB.b.pretty)")
            output.append("  > shader:   l: \(mLAB2.x.pretty), a: \(mLAB2.y.pretty), b: \(mLAB2.z.pretty)")
            
            XCTAssertEqual(mLAB2.x, eLAB.l, accuracy: 1)
            XCTAssertEqual(mLAB2.y, eLAB.a, accuracy: 1)
            XCTAssertEqual(mLAB2.z, eLAB.b, accuracy: 1)
            
            let mXYZ2 = convertFromLAB2XYZ(mLAB2)
            output.append("  === LAB to XYZ ===")
            output.append("  > expect:   x: \(eXYZ.x.pretty), y: \(eXYZ.y.pretty), z: \(eXYZ.z.pretty)")
            output.append("  > shader:   x: \(mXYZ2.x.pretty), y: \(mXYZ2.y.pretty), z: \(mXYZ2.z.pretty)")
            
            XCTAssertEqual(mXYZ2.x, eXYZ.x, accuracy: 1)
            XCTAssertEqual(mXYZ2.y, eXYZ.y, accuracy: 1)
            XCTAssertEqual(mXYZ2.z, eXYZ.z, accuracy: 1)
            
            let mRGB = convertFromXYZ2RGB(mXYZ2)
            output.append("  === XYZ to RGB ===")
            output.append("  > expect:   r: \(color.x.pretty), g: \(color.y.pretty), b: \(color.z.pretty)")
            output.append("  > shader:   r: \(mRGB.x.pretty), g: \(mRGB.y.pretty), b: \(mRGB.z.pretty)")
            
            XCTAssertEqual(mRGB.x, color.x, accuracy: 0.01)
            XCTAssertEqual(mRGB.y, color.y, accuracy: 0.01)
            XCTAssertEqual(mRGB.z, color.z, accuracy: 0.01)

            print(output.joined(separator: "\n"))
        }
    }
}

extension Float {
    var pretty: String {
        String(format: "%.5f", self)
    }
}
