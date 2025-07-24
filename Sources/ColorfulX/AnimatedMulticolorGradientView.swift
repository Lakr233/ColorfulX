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
    threshold: 0.0001,
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

    public private(set) var speckles: [Speckle] {
        didSet { renderInputWasModified = true }
    }

    private let specklesAccessLock = NSLock()

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
        speckles = .init(repeating: .init(position: SPRING_ENGINE), count: Uniforms.COLOR_SLOT)
        super.init()
        initializeRenderParameters()
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
        speckles
            .filter(\.enabled)
            .allSatisfy(\.isTransitionCompleted)
    }

    @inline(__always)
    public func shouldRenderNextFrameWithinSynchornization() -> Bool {
        guard frameLimiterShouldScheduleNextFrame() else { return false }
        // if transition not completed, keep ticking until complete
        if !isColorTransitionCompleted() { return true }
        guard speed > 0 || renderInputWasModified else { return false }
        return true
    }

    // MARK: - RENDER LIFE CYCLE

    #if canImport(UIKit)
        override open func didMoveToWindow() {
            super.didMoveToWindow()
            if window != nil {
                // Use CATransaction to ensure execution in the next run loop
                CATransaction.begin()
                CATransaction.setCompletionBlock { [weak self] in
                    self?.layoutIfNeeded()
                    self?.updateRenderParameters(deltaTime: 0) // No animation needed during initialization
                    self?.renderIfNeeded()
                }
                CATransaction.commit()
            }
        }
    #endif

    #if !canImport(UIKit) && canImport(AppKit)
        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            layoutSubtreeIfNeeded()
            updateRenderParameters(deltaTime: deltaTimeForRenderParametersUpdate())
            renderIfNeeded()
        }
    #endif

    override func render() {
        super.render()
        lastRenderExecution = obtainCurrentTimestamp()
    }

    override func vsync() {
        guard shouldRenderNextFrameWithinSynchornization() else { return }
        updateRenderParameters(deltaTime: deltaTimeForRenderParametersUpdate())
        super.vsync()
    }

    func alteringSpeckles(_ callback: (inout [Speckle]) -> Void) {
        specklesAccessLock.lock()
        callback(&speckles)
        specklesAccessLock.unlock()
    }

    func alteringSpeckleByIteratingValues(_ callback: (inout Speckle) -> Void) {
        alteringSpeckleByIteratingValues { speckle, _ in callback(&speckle) }
    }

    func alteringSpeckleByIteratingValues(_ callback: (inout Speckle, _ idx: Int) -> Void) {
        specklesAccessLock.lock()
        for idx in 0 ..< speckles.count {
            callback(&speckles[idx], idx)
        }
        specklesAccessLock.unlock()
    }
}
