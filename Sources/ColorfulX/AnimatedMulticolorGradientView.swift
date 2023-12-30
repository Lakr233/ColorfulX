//
//  AnimatedMulticolorGradientView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import MetalKit
import SpringInterpolation

private let COLOR_SLOT = 8
private let SPRING_CONFIG = SpringInterpolation.Configuration(
    angularFrequency: 1.5,
    dampingRatio: 0.2
)
private let SPRING_ENGINE = SpringInterpolation2D(SPRING_CONFIG)

public class AnimatedMulticolorGradientView: MulticolorGradientView {
    public private(set) var lastUpdate = Date()
    public private(set) var colorElements: [Speckle]

    public var speed: Double = 1.0
    public var noise: Double = 0
    public var transitionDuration: TimeInterval = 5

    public var frameLimit: Int = 60
    public private(set) var lastRender: Date = .init(timeIntervalSince1970: 0)

    override public init() {
        colorElements = .init(repeating: .init(position: SPRING_ENGINE), count: COLOR_SLOT)

        super.init()

        var rand = randomLocationPair()
        for idx in 0 ..< colorElements.count {
            rand = randomLocationPair()
            colorElements[idx].position.setCurrent(.init(x: rand.x, y: rand.y))
            rand = randomLocationPair()
            colorElements[idx].position.setTarget(.init(x: rand.x, y: rand.y))
        }
    }

    private func randomLocationPair() -> (x: Double, y: Double) {
        (
            x: Double.random(in: 0 ... 1),
            y: Double.random(in: 0 ... 1)
        )
    }

    public func setColors(_ colors: [RGBColor], interpolationEnabled: Bool = true) {
        assert(Thread.isMainThread)
        for idx in 0 ..< COLOR_SLOT {
            var read = colorElements[idx]
            let color: RGBColor = colors.isEmpty
                ? RGBColor(r: 0.5, g: 0.5, b: 0.5)
                : colors[idx % colors.count]
            guard read.targetColor != color else { continue }
            let interpolationEnabled = interpolationEnabled && read.enabled
            let currentColor = read.currentColor
            read.enabled = true
            read.targetColor = color
            read.previousColor = interpolationEnabled ? currentColor : color
            read.transitionProgress = interpolationEnabled ? 0 : 1
            colorElements[idx] = read
        }
    }

    private func updateRenderParameters() {
        let deltaTime = -lastUpdate.timeIntervalSinceNow
        lastUpdate = Date()
        guard deltaTime > 0 else {
            assertionFailure()
            return
        }

        let moveDelta = deltaTime * speed * 0.5 // just slow down

        for idx in 0 ..< colorElements.count where colorElements[idx].enabled {
            var inplaceEdit = colorElements[idx]
            defer { colorElements[idx] = inplaceEdit }

            if inplaceEdit.transitionProgress < 1 {
                inplaceEdit.transitionProgress += deltaTime / transitionDuration
            }
            if moveDelta > 0 {
                inplaceEdit.position.update(withDeltaTime: moveDelta)

                let pos_x = inplaceEdit.position.x.context.currentPos
                let tar_x = inplaceEdit.position.x.context.targetPos
                let pos_y = inplaceEdit.position.y.context.currentPos
                let tar_y = inplaceEdit.position.y.context.targetPos
                if abs(pos_x - tar_x) < 0.125 || abs(pos_y - tar_y) < 0.125 {
                    let rand = randomLocationPair()
                    inplaceEdit.position.setTarget(.init(x: rand.x, y: rand.y))
                }
            }
        }

        parameters = .init(
            points: colorElements
                .filter(\.enabled)
                .map { .init(
                    color: $0.currentColor,
                    position: .init(
                        x: $0.position.x.context.currentPos,
                        y: $0.position.y.context.currentPos
                    )
                ) },
            noise: Float(noise)
        )
    }

    override func vsync() {
        guard Date().timeIntervalSince(lastRender) > 1.0 / Double(frameLimit) else {
            return
        }
        lastRender = Date()
        updateRenderParameters()
        super.vsync()
    }
}
