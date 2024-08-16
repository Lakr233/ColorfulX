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
        var rand = randomLocationPair()
        for idx in 0 ..< speckles.count {
            rand = randomLocationPair()
            alteringSpeckles { speckles in
                speckles[idx].position.setCurrent(.init(x: rand.x, y: rand.y))
                rand = randomLocationPair()
                speckles[idx].position.setTarget(.init(x: rand.x, y: rand.y))
            }
        }
    }

    func updateRenderParameters(deltaTime: Double) {
        defer { renderInputWasModified = false }

        let moveDelta = deltaTime * speed * 0.5 // just slow down

        var points: [MulticolorGradientView.Parameters.ColorStop]?
        alteringSpeckles { speckles in
            for idx in 0 ..< speckles.count where speckles[idx].enabled {
                if speckles[idx].transitionProgress.context.currentPos < 1 {
                    speckles[idx].transitionProgress.update(withDeltaTime: deltaTime * transitionSpeed)
                }
                if moveDelta > 0 {
                    speckles[idx].position.update(withDeltaTime: moveDelta)

                    let pos_x = speckles[idx].position.x.context.currentPos
                    let tar_x = speckles[idx].position.x.context.targetPos
                    let pos_y = speckles[idx].position.y.context.currentPos
                    let tar_y = speckles[idx].position.y.context.targetPos
                    if abs(pos_x - tar_x) < 0.125 || abs(pos_y - tar_y) < 0.125 {
                        let rand = randomLocationPair()
                        speckles[idx].position.setTarget(.init(x: rand.x, y: rand.y))
                    }
                }
            }

            points = speckles
                .filter(\.enabled)
                .map { .init(
                    color: $0.colorVector,
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
