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
        self + (newValue - self) * delta
    }
}

extension Float: Lerpable {
    func lerp(to newValue: Self, percent delta: Double) -> Self {
        self + (newValue - self) * Float(delta)
    }
}

extension RGBColor {
    func lerpWithLCH(to: RGBColor, percent delta: Double) -> RGBColor {
        if delta <= 0 { return self }
        if delta >= 1 { return to }
        let fromValue = lch
        let toValue = to.lch
        let result: (v0: Float, v1: Float, v2: Float) = (
            fromValue.l + (toValue.l - fromValue.l) * Float(delta),
            fromValue.c + (toValue.c - fromValue.c) * Float(delta),
            fromValue.h + (toValue.h - fromValue.h) * Float(delta)
        )
        return .init(l: result.v0, c: result.v1, h: result.v2)
    }

    func lerpWithLAB(to: RGBColor, percent delta: Double) -> RGBColor {
        if delta <= 0 { return self }
        if delta >= 1 { return to }
        let fromValue = lab
        let toValue = to.lab
        let result: (v0: Float, v1: Float, v2: Float) = (
            fromValue.l + (toValue.l - fromValue.l) * Float(delta),
            fromValue.a + (toValue.a - fromValue.a) * Float(delta),
            fromValue.b + (toValue.b - fromValue.b) * Float(delta)
        )
        return .init(l: result.v0, a: result.v1, b: result.v2)
    }

    func lerpWithXYZ(to: RGBColor, percent delta: Double) -> RGBColor {
        if delta <= 0 { return self }
        if delta >= 1 { return to }
        let fromValue = xyz
        let toValue = to.xyz
        let result: (v0: Float, v1: Float, v2: Float) = (
            fromValue.x + (toValue.x - fromValue.x) * Float(delta),
            fromValue.y + (toValue.y - fromValue.y) * Float(delta),
            fromValue.z + (toValue.z - fromValue.z) * Float(delta)
        )
        return .init(x: result.v0, y: result.v1, z: result.v2)
    }

    func lerpWithRGB(to: RGBColor, percent delta: Double) -> RGBColor {
        if delta <= 0 { return self }
        if delta >= 1 { return to }
        let fromValue = self
        let toValue = to
        let result: (v0: Float, v1: Float, v2: Float) = (
            fromValue.r + (toValue.r - fromValue.r) * Float(delta),
            fromValue.g + (toValue.g - fromValue.g) * Float(delta),
            fromValue.b + (toValue.b - fromValue.b) * Float(delta)
        )
        return .init(r: result.v0, g: result.v1, b: result.v2)
    }
}
