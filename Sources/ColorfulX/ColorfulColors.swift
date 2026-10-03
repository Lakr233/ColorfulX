//
//  ColorfulColors.swift
//
//
//  Created by 秋星桥 on 2024/9/11.
//

import Foundation

public protocol ColorfulColors {
    var colors: [ColorElement] { get }

    func make(_ r: Int, _ g: Int, _ b: Int, _ a: Int) -> ColorElement
}

public extension ColorfulColors {
    func make(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 255) -> ColorElement {
        ColorElement(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255,
        )
    }
}
