//
//  AnimatedMulticolorGradientView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
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

        #if canImport(UIKit)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationWillEnterForeground(_:)),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        #endif
    }

    #if canImport(UIKit)
        @objc
        func applicationWillEnterForeground(_: Notification) {
            lastRender = .init()
            needsUpdateRenderParameters = true
        }
    #endif

    deinit {
        #if canImport(UIKit)
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        #endif
    }

    public func setColors(_ colors: [ColorVector], interpolationEnabled: Bool = true) {
        var colors = colors
        if colors.isEmpty { colors.append(.init(v: .zero, space: .rgb)) }
        colors = colors.map { $0.color(in: .lab) }

        for idx in 0 ..< Uniforms.COLOR_SLOT {
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
        // when calling from vsync, MetalView is holding strong reference.
        DispatchQueue.main.asyncAndWait(execute: DispatchWorkItem {
            if self.frameLimit > 0 {
                let now = Date().timeIntervalSince1970
                guard now - self.lastRender > 1.0 / Double(self.frameLimit) else { return }
                self.lastRender = now
            }
            self.updateRenderParameters()
        })
    }

    func computeSpeckleColor(_ speckle: Speckle) -> ColorVector {
        let progress = speckle.transitionProgress.context.currentPos
        return speckle.previousColor.lerp(to: speckle.targetColor, percent: progress)
    }
}
