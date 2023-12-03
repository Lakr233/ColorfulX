//
//  AnimatedMulticolorGradientView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import MetalKit
import SpringInterpolation

private let COLOR_SLOT = 8
private let LOCATION_OVERSHOT = 0.25

public class AnimatedMulticolorGradientView: MulticolorGradientView {
    public let fps: Int
    public let deltaTime: Double

    public private(set) var colorElements: [ColorElement]
    public private(set) var colorMoveSpeedFactor: Double = 1.0
    public private(set) var colorTransitionDuration: TimeInterval = 5

    public private(set) var lastDraw: Date = .init()
    private var timers: [Timer] = []

    /// create with animation to render
    /// - Parameters:
    ///   - fps: frame per second
    ///   - colorTransitionDuration: used in color interpolation
    ///   - colorMoveSpeedFactor: used in location animation with spring interpolation
    public init(fps: Int) {
        self.fps = fps
        deltaTime = 1.0 / Double(fps)

        var buildElements = [ColorElement]()
        for _ in 0 ..< COLOR_SLOT {
            buildElements.append(.init(
                enabled: false,
                targetColor: .init(r: 0.5, g: 0.5, b: 0.5),
                previousColor: .init(r: 0.5, g: 0.5, b: 0.5),
                transitionProgress: 1,
                position: .init(.init())
            ))
        }
        colorElements = buildElements

        super.init()

        for idx in 0 ..< buildElements.count {
            var rand = randomLocationPair()
            colorElements[idx].position.setCurrent(.init(x: rand.x, y: rand.y))
            rand = randomLocationPair()
            colorElements[idx].position.setTarget(.init(x: rand.x, y: rand.y))
        }

        setSpeedFactor(1.0)

        timers.append(.init(
            timeInterval: 1.0 / Double(fps),
            target: self,
            selector: #selector(updateTik),
            userInfo: nil,
            repeats: true
        ))
        timers.forEach {
            RunLoop.main.add($0, forMode: .common)
        }
    }

    deinit {
        timers = timers.compactMap { timer in
            timer.invalidate()
            return nil
        }
    }

    @objc func updateTik() {
        assert(Thread.isMainThread)
        for idx in 0 ..< colorElements.count where colorElements[idx].enabled {
            var read = colorElements[idx]
            defer { colorElements[idx] = read }

            if read.transitionProgress < 1 {
                read.transitionProgress += deltaTime / colorTransitionDuration
            }
            // if approaching to target, generate new target
            let currentPos = read.position.currentPos
            let targetPos = read.position.targetPos
            read.position.tik()

            if abs(currentPos.x - targetPos.x) < LOCATION_OVERSHOT / 2,
               abs(currentPos.y - targetPos.y) < LOCATION_OVERSHOT / 2
            {
                let rand = randomLocationPair()
//                print("[*] setting \(idx) new rand \(rand)")
                read.position.setTarget(.init(x: rand.x, y: rand.y))
            }
        }
    }

    private func randomLocationPair() -> (x: Double, y: Double) {
        let ret = (
            // allow out of range for the color stop location
            // shader will deal it
            x: Double.random(in: -LOCATION_OVERSHOT ... (1 + LOCATION_OVERSHOT)),
            y: Double.random(in: -LOCATION_OVERSHOT ... (1 + LOCATION_OVERSHOT))
        )
        return ret
    }

    public func setColors(_ colors: [RGBColor], interpolationEnabled: Bool = true) {
        assert(Thread.isMainThread)
        for (idx, color) in colors.enumerated() {
            var read = colorElements[idx]
            // ignore unchanged request
            guard read.targetColor != color else { continue }
            let interpolationEnabled = interpolationEnabled && read.enabled
//            print("[*] updating color -> \(color)")
//            print("    interpolationEnabled \(interpolationEnabled)")
            let currentColor = read.currentColor // make copy first then edit
            read.enabled = true
            read.targetColor = color
            read.previousColor = interpolationEnabled ? currentColor : color
            read.transitionProgress = interpolationEnabled ? 0 : 1
            colorElements[idx] = read
        }
        for idx in colors.count ..< colorElements.count {
            colorElements[idx].enabled = false
        }
//        print("")
    }

    public func setSpeedFactor(_ value: Double) {
        assert(Thread.isMainThread)

        colorMoveSpeedFactor = value
        for idx in 0 ..< colorElements.count {
            let currentPos = colorElements[idx].position
            // re init!
            colorElements[idx].position = .init(.init(deltaTime: deltaTime * value / 5))
            colorElements[idx].position.setCurrent(
                currentPos.currentPos,
                vel: currentPos.currentVel
            )
            colorElements[idx].position.setTarget(currentPos.targetPos)
        }
    }

    public func setColorTransitionDuration(_ value: TimeInterval) {
        colorTransitionDuration = value
    }

    override public func draw(in _: MTKView) {
        guard let drawable = currentDrawable else { return }
        let updateDelta = Date().timeIntervalSince(lastDraw)
        assert(updateDelta > 0)
        lastDraw = Date()
        computeParameters()
        draw(with: parameters, in: drawable)
    }

    func computeParameters() {
        parameters = .init(
            points: colorElements
                .filter(\.enabled)
                .map { .init(
                    color: $0.currentColor,
                    position: .init(
                        x: $0.position.currentPos.x,
                        y: $0.position.currentPos.y
                    )
                ) },
            noise: 8
        )
    }
}
