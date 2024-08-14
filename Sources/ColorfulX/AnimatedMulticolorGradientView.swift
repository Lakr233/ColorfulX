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
    dampingRatio: 0.2,
    threshold: 0.001,
    stopWhenHitTarget: true
)
private let SPRING_ENGINE = SpringInterpolation2D(SPRING_CONFIG)
private let defaultFrameRate: Int = 60

open class AnimatedMulticolorGradientView: MulticolorGradientView {
    // MARK: - PROPERTY

    public private(set) var lastRenderParametersUpdate: Double = 0
    public private(set) var lastRenderExecution: Double = 0
    public var renderInputWasModified: Bool = false {
        didSet { lastRenderParametersUpdate = obtainCurrentTimestamp() }
    }

    public internal(set) var colorElements: [Speckle] {
        didSet { renderInputWasModified = true }
    }

    public var speed: Double = 1.0 {
        didSet { renderInputWasModified = true }
    }

    public var bias: Double = 0.01 {
        didSet { renderInputWasModified = true }
    }

    public var noise: Double = 0 {
        didSet { renderInputWasModified = true }
    }

    public var transitionSpeed: Double = 1 {
        didSet { renderInputWasModified = true }
    }

    public var frameLimit: Int = 0 {
        didSet { renderInputWasModified = true }
    }

    // MARK: - FUNCTION

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

    // MARK: - GETTER

    @inline(__always)
    func obtainCurrentTimestamp() -> Double { CACurrentMediaTime() }

    @inline(__always)
    func frameLimiterShouldScheduleNextFrame() -> Bool {
        guard frameLimit > 0 else { return true }

        let currentTime = obtainCurrentTimestamp()
        let deltaTime = currentTime - lastRenderExecution
        let requiredDeltaTime = 1.0 / Double(frameLimit)

        let nextTierFrameRate = Double(frameLimit * 2)
        let nextTierDeltaTime = 1.0 / nextTierFrameRate

        let decisionDeltaTime = requiredDeltaTime - nextTierDeltaTime

        return deltaTime >= decisionDeltaTime

        /*
         we are not dead loop here so vsync already delays for 16ms in 60hz display
         if we give and one frame each time, there would be 30 fps to actually draw on display

         based on this fact, frame limit can be 7, 15, 30, 60, 120...
         requiredDeltaTime needs to shift in order to comply with our goal
         */
    }

    @inline(__always)
    private func deltaTimeForRenderParametersUpdate() -> Double {
        let currentTime = obtainCurrentTimestamp()
        let realDeltaTime = currentTime - lastRenderParametersUpdate
        var frameRate = frameLimit
        if frameRate < 1 { frameRate = defaultFrameRate }
        let maxAllowedDeltaTime = 1.0 / Double(frameRate)
        if realDeltaTime > maxAllowedDeltaTime { return maxAllowedDeltaTime }
        return realDeltaTime
    }

    @inline(__always)
    func isColorTransitionCompleted() -> Bool {
        colorElements
            .filter(\.enabled)
            .allSatisfy { $0.transitionProgress.context.currentPos >= 1 }
    }

    @inline(__always)
    public func shouldRenderNextFrameWithinSynchornization() -> Bool {
        // if transition not completed, keep ticking until complete
        if !isColorTransitionCompleted() { return true }
        guard frameLimiterShouldScheduleNextFrame() else { return false }
        guard speed > 0 || renderInputWasModified else { return false }
        return true
    }

    // MARK: - RENDER LIFE CYCLE

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        // skip any vsync check and force an update
        renderInputWasModified = true
        updateRenderParameters(deltaTime: deltaTimeForRenderParametersUpdate())
        renderIfNeeded()
    }

    override func renderIfNeeded() {
        super.renderIfNeeded()
    }

    override func render() {
        super.render()
        lastRenderExecution = obtainCurrentTimestamp()
    }

    override func vsync() {
        guard shouldRenderNextFrameWithinSynchornization() else { return }
        updateRenderParameters(deltaTime: deltaTimeForRenderParametersUpdate())
        // sine the render parameters were updated, we call super.vsync to render
        super.vsync()
    }

    func computeSpeckleColor(_ speckle: Speckle) -> ColorVector {
        let progress = speckle.transitionProgress.context.currentPos
        return speckle.previousColor.lerp(to: speckle.targetColor, percent: progress)
    }
}
