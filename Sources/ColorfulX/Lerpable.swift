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
        if delta <= 0 { return self }
        if delta >= 1 { return to }
        let lchFrom = lch
        let lchTo = to.lch
        let lerpLch: (l: Float, c: Float, h: Float) = (
            lchFrom.l + (lchTo.l - lchFrom.l) * Float(delta),
            lchFrom.c + (lchTo.c - lchFrom.c) * Float(delta),
            lchFrom.h + (lchTo.h - lchFrom.h) * Float(delta)
        )
        return .init(l: lerpLch.l, c: lerpLch.c, h: lerpLch.h)
    }
}
