//
//  AnimatedMulticolorGradientView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import CoreFoundation
import MetalKit
import SpringInterpolation

private let SPRING_CONFIG = SpringInterpolation.Configuration(
    angularFrequency: 1.5,
    dampingRatio: 0.2
)
private let SPRING_ENGINE = SpringInterpolation2D(SPRING_CONFIG)

open class AnimatedMulticolorGradientView: MulticolorGradientView {
    public var lastUpdate: Double = 0
    public var lastRender: Double = 0
    public var needsUpdateRenderParameters: Bool = false

    public internal(set) var colorElements: [Speckle] {
        didSet { needsUpdateRenderParameters = true }
    }

    public var speed: Double = 1.0 {
        didSet { needsUpdateRenderParameters = true }
    }

    public var bias: Double = 0.01 {
        didSet { needsUpdateRenderParameters = true }
    }

    public var noise: Double = 0 {
        didSet { needsUpdateRenderParameters = true }
    }

    public var transitionSpeed: Double = 1 {
        didSet { needsUpdateRenderParameters = true }
    }

    public var frameLimit: Int = 0 {
        didSet { needsUpdateRenderParameters = true }
    }

    override public init() {
        colorElements = .init(repeating: .init(position: SPRING_ENGINE), count: Uniforms.COLOR_SLOT)
        super.init()
        initializeRenderParameters()
    }

    public func setColors(_ colors: [ColorVector], interpolationEnabled: Bool = true, repeatToFillColorSlots: Bool = true) {
        var colors = colors
        if colors.isEmpty { colors.append(.init(v: .zero, space: .rgb)) }
        colors = colors.map { $0.color(in: .lab) }

        let endingIndex = repeatToFillColorSlots ? Uniforms.COLOR_SLOT : min(colors.count, Uniforms.COLOR_SLOT)
        guard endingIndex > 0 else { return }
        for idx in 0 ..< endingIndex {
            var read = colorElements[idx]
            let color: ColorVector = colors[idx % colors.count]
            guard read.targetColor != color else { continue }
            let interpolationEnabled = interpolationEnabled && read.enabled
            let currentColor = computeSpeckleColor(read)
            read.enabled = true
            read.targetColor = color
            read.previousColor = interpolationEnabled ? currentColor : color
            read.transitionProgress.setCurrent(interpolationEnabled ? 0 : 1, 0)
            colorElements[idx] = read
        }
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        needsUpdateRenderParameters = true
        updateRenderParameters()
        super.vsync()
    }

    override func vsync() {
        defer { super.vsync() }
        guard needsUpdateRenderParameters || speed > 0 else { return }
        defer { self.updateRenderParameters() }
        guard frameLimit > 0 else { return }

        var decisionFrameRate = frameLimit - 1
        if decisionFrameRate < 1 { decisionFrameRate = 1 }
        let wantedDeltaTime = 1.0 / Double(decisionFrameRate)
        let now = CACurrentMediaTime()
        guard now - lastUpdate >= wantedDeltaTime else { return }
        lastRender = now
    }

    func computeSpeckleColor(_ speckle: Speckle) -> ColorVector {
        let progress = speckle.transitionProgress.context.currentPos
        return speckle.previousColor.lerp(to: speckle.targetColor, percent: progress)
    }
}
