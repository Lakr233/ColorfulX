//
//  AnimatedMulticolorGradientView+Update.swift
//
//
//  Created by 秋星桥 on 2024/8/12.
//

import Foundation

extension AnimatedMulticolorGradientView {
    func initializeRenderParameters() {
        animationDirector.initialize()
    }

    func updateRenderParameters(deltaTime: Double) {
        defer { renderInputWasModified = false }
        animationDirector.update(deltaTime: deltaTime)
    }
}
