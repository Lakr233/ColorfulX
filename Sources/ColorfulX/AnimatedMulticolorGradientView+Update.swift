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
        for idx in 0 ..< colorElements.count {
            rand = randomLocationPair()
            colorElements[idx].position.setCurrent(.init(x: rand.x, y: rand.y))
            rand = randomLocationPair()
            colorElements[idx].position.setTarget(.init(x: rand.x, y: rand.y))
        }
    }

    func updateRenderParameters(deltaTime: Double) {
        // clear the flag
        defer { renderInputWasModified = false }

        let moveDelta = deltaTime * speed * 0.5 // just slow down

        for idx in 0 ..< colorElements.count where colorElements[idx].enabled {
            var inplaceEdit = colorElements[idx]
            defer { colorElements[idx] = inplaceEdit }

            if inplaceEdit.transitionProgress.context.currentPos < 1 {
                inplaceEdit.transitionProgress.update(withDeltaTime: deltaTime * transitionSpeed)
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
                    color: computeSpeckleColor($0),
                    position: .init(
                        x: $0.position.x.context.currentPos,
                        y: $0.position.y.context.currentPos
                    )
                ) },
            bias: bias,
            noise: noise
        )
    }
}
