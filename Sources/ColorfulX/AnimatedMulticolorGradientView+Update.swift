//
//  AnimatedMulticolorGradientView+Update.swift
//
//
//  Created by 秋星桥 on 2024/8/12.
//

import Foundation

extension AnimatedMulticolorGradientView {
    private func randomLocationPair() -> (x: Double, y: Double) {
        (
            x: Double.random(in: 0 ... 1),
            y: Double.random(in: 0 ... 1)
        )
    }

    func initializeRenderParameters() {
        alteringSpeckleByIteratingValues { speckle in
            let rand = randomLocationPair()
            speckle.transitionProgress.setTarget(1)
            speckle.position.setCurrent(.init(x: rand.x, y: rand.y))
            speckle.position.setTarget(.init(x: rand.x, y: rand.y))
        }
    }

    func updateRenderParameters(deltaTime: Double) {
        defer { renderInputWasModified = false }

        let moveDelta = deltaTime * speed * 0.5 // just slow down

        alteringSpeckleByIteratingValues { speckle in
            if speckle.transitionProgress.context.currentPos < 1 {
                speckle.transitionProgress.update(withDeltaTime: deltaTime * transitionSpeed)
            }

            if moveDelta > 0 {
                speckle.position.update(withDeltaTime: moveDelta)
            }

            let pos_x = speckle.position.x.context.currentPos
            let tar_x = speckle.position.x.context.targetPos
            let pos_y = speckle.position.y.context.currentPos
            let tar_y = speckle.position.y.context.targetPos
            let shouldUpdateLocation = false
                || abs(pos_x - tar_x) < 0.125
                || abs(pos_y - tar_y) < 0.125

            if shouldUpdateLocation {
                let rand = randomLocationPair()
                speckle.position.setTarget(.init(x: rand.x, y: rand.y))
            }
        }

        var points: [MulticolorGradientView.Parameters.ColorStop]?

        alteringSpeckles { speckles in
            points = speckles.filter(\.enabled).map { .init(
                color: $0.color,
                position: .init(
                    x: $0.position.x.context.currentPos,
                    y: $0.position.y.context.currentPos
                )
            ) }
        }
        guard let points else { return }

        parameters = .init(
            points: points,
            bias: bias,
            noise: noise
        )
    }
}
