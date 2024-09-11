//
//  main.swift
//
//
//  Created by 秋星桥 on 2024/8/16.
//

import ColorfulX
import Foundation
import SwiftUI

CompilerCheck.stub()

App.main()

enum MyPresets: ColorfulColors {
    case white

    var colors: [ColorElement] {
        [
            make(255, 255, 255),
            make(244, 244, 244),
            make(233, 233, 233),
            make(222, 222, 222),
        ]
    }
}

enum CompilerCheck {
    static func stub() {
        _ = ColorfulView(color: [.white])
        _ = ColorfulView(color: MyPresets.white)
        _ = ColorfulView(color: ColorfulPreset.appleIntelligence)
        _ = ColorfulView(color: .init(get: { ColorfulPreset.appleIntelligence }, set: { _ in }))
        _ = ColorfulView(color: .init(get: { [Color.white] }, set: { _ in }))

        let view = AnimatedMulticolorGradientView()
        view.setColors(.appleIntelligence)
        view.setColors(MyPresets.white)
    }
}
