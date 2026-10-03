//
//  SpeckleAnimationRandomDirector.swift
//
//
//  Created by GitHub Copilot on 2025/10/12.
//

import Foundation

open class SpeckleAnimationRandomDirector: SpeckleAnimationDirector {
    override open func initializeSpeckle(
        _ speckle: inout AnimatedMulticolorGradientView.Speckle,
        index _: Int,
    ) {
        let location = randomLocation()
        speckle.position.setCurrent(.init(x: location.x, y: location.y))
        speckle.position.setTarget(.init(x: location.x, y: location.y))
        view?.renderInputWasModified = true
    }

    override open func updateSpeckle(
        _ speckle: inout AnimatedMulticolorGradientView.Speckle,
        index: Int,
        deltaTime: Double,
    ) {
        super.updateSpeckle(&speckle, index: index, deltaTime: deltaTime)
        guard let view else { return }
        let moveDelta = deltaTime * view.speed * 0.5
        if moveDelta > 0 {
            speckle.position.update(withDeltaTime: moveDelta)
        }

        let currentX = speckle.position.x.context.currentPos
        let targetX = speckle.position.x.context.targetPos
        let currentY = speckle.position.y.context.currentPos
        let targetY = speckle.position.y.context.targetPos
        let shouldUpdateLocation = abs(currentX - targetX) < 0.125 || abs(currentY - targetY) < 0.125
        if shouldUpdateLocation {
            let location = randomLocation()
            speckle.position.setTarget(.init(x: location.x, y: location.y))
            view.renderInputWasModified = true
        }
    }

    private func randomLocation() -> (x: Double, y: Double) {
        (
            x: Double.random(in: 0 ... 1),
            y: Double.random(in: 0 ... 1),
        )
    }
}
