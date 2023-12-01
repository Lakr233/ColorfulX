//
//  CoreColor.swift
//
//
//  Created by QAQ on 2023/12/1.
//

import SwiftUI

#if canImport(UIKit)
    typealias CoreColor = UIColor
#else
    #if canImport(AppKit)
        typealias CoreColor = NSColor
    #else
        #error("unsupported platform")
    #endif
#endif

extension Color {
    func lerp(to: Color, t: Double) -> Color {
        let colorA = CoreColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        colorA.getRed(&r, green: &g, blue: &b, alpha: nil)

        let colorB = CoreColor(to)
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        colorB.getRed(&r2, green: &g2, blue: &b2, alpha: nil)

        return Color(
            red: r + (r2 - r) * t,
            green: g + (g2 - g) * t,
            blue: b + (b2 - b) * t
        )
    }

    func lerpHSB(to: Color, t: Double) -> Color {
        let colorA = CoreColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        colorA.getHue(&h, saturation: &s, brightness: &b, alpha: nil)

        let colorB = CoreColor(to)
        var h2: CGFloat = 0
        var s2: CGFloat = 0
        var b2: CGFloat = 0
        colorB.getHue(&h2, saturation: &s2, brightness: &b2, alpha: nil)

        return Color(
            hue: h + (h2 - h) * t,
            saturation: s + (s2 - s) * t,
            brightness: b + (b2 - b) * t
        )
    }
}
