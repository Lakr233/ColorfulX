//
//  Lerpable.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import MetalKit

protocol Lerpable {
    func lerp(to newValue: Self, percent delta: Double) -> Self
}

extension Double: Lerpable {
    func lerp(to newValue: Self, percent delta: Double) -> Self {
        assert(delta >= 0 && delta <= 1)

        return self + (newValue - self) * delta
    }
}

extension Float: Lerpable {
    func lerp(to newValue: Self, percent delta: Double) -> Self {
        assert(delta >= 0 && delta <= 1)

        return self + (newValue - self) * Float(delta)
    }
}

extension RGBColor: Lerpable {
    func lerp(to: RGBColor, percent delta: Double) -> RGBColor {
        assert(delta >= 0 && delta <= 1)

        let colorFrom = coreColor
        let colorTo = to.coreColor

        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        colorFrom.getHue(&h, saturation: &s, brightness: &b, alpha: nil)

        var h2: CGFloat = 0
        var s2: CGFloat = 0
        var b2: CGFloat = 0
        colorTo.getHue(&h2, saturation: &s2, brightness: &b2, alpha: nil)

        let inter = CoreColor(
            hue: h + (h2 - h) * delta,
            saturation: s + (s2 - s) * delta,
            brightness: b + (b2 - b) * delta,
            alpha: 1
        )
        return .init(inter)
    }
}
