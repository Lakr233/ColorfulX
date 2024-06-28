//
//  Color.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public struct RGBColor: Equatable {
    public var r: Float
    public var g: Float
    public var b: Float

    public init(r: Float, g: Float, b: Float) {
        self.r = r
        self.g = g
        self.b = b
    }
}

#if canImport(UIKit)
    import UIKit

    public typealias CoreColor = UIColor
#else
    #if canImport(AppKit)
        import AppKit

        public typealias CoreColor = NSColor
    #else
        #error("unsupported platform")
    #endif
#endif

public extension RGBColor {
    var coreColor: CoreColor {
        CoreColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
    }

    init(_ color: CoreColor) {
        guard let colorspaceSRGB = CGColorSpace(name: CGColorSpace.sRGB),
              let cgColor = color.cgColor.converted(
                  to: colorspaceSRGB,
                  intent: .defaultIntent,
                  options: nil
              )
        else {
            self.init(r: 0, g: 0, b: 0)
            return
        }
        self.init(
            r: Float(cgColor.components?[0] ?? 0),
            g: Float(cgColor.components?[1] ?? 0),
            b: Float(cgColor.components?[2] ?? 0)
        )
    }
}

struct LCHColor: Codable, Equatable, Hashable {
    var l: Float
    var c: Float
    var h: Float

    init(l: Float, c: Float, h: Float) {
        self.l = l
        self.c = c
        self.h = h
    }

    init(color: RGBColor) {
        let lch = color.lch
        self.init(l: lch.l, c: lch.c, h: lch.h)
    }
}

private extension Float {
    var positive: Float {
        if self < 0 { return 0 }
        return self
    }
}

public extension RGBColor {
    var xyz: (x: Float, y: Float, z: Float) {
        var r = self.r
        var g = self.g
        var b = self.b

        if r > 0.04045 {
            r = pow((r + 0.055) / 1.055, 2.4)
        } else {
            r = r / 12.92
        }
        if g > 0.04045 {
            g = pow((g + 0.055) / 1.055, 2.4)
        } else {
            g = g / 12.92
        }
        if b > 0.04045 {
            b = pow((b + 0.055) / 1.055, 2.4)
        } else {
            b = b / 12.92
        }
        r *= 100
        g *= 100
        b *= 100

        // Observer = 2°, Illuminant = D65
        let x = r * 0.4124 + g * 0.3576 + b * 0.1805
        let y = r * 0.2126 + g * 0.7152 + b * 0.0722
        let z = r * 0.0193 + g * 0.1192 + b * 0.9505

        return (x, y, z)
    }

    var lab: (l: Float, a: Float, b: Float) {
        let xyz = self.xyz
        var vx = xyz.x / 95.047
        var vy = xyz.y / 100.000
        var vz = xyz.z / 108.883

        if vx > 0.008856 {
            vx = pow(vx, 0.333333333)
        } else {
            vx = 7.787 * vx + 0.137931034
        }

        if vy > 0.008856 {
            vy = pow(vy, 0.333333333)
        } else {
            vy = 7.787 * vy + 0.137931034
        }

        if vz > 0.008856 {
            vz = pow(vz, 0.333333333)
        } else {
            vz = 7.787 * vz + 0.137931034
        }

        let l = (116.0 * vy) - 16.0
        let a = 500.0 * (vx - vy)
        let b = 200.0 * (vy - vz)
        return (l, a, b)
    }

    var lch: (l: Float, c: Float, h: Float) {
        let l = lab.l
        let a = lab.a
        let b = lab.b

        let c = sqrt(pow(a, 2) + pow(b, 2))

        var h = atan2(b, a)
        if h > 0 {
            h = (h / .pi) * 180
        } else {
            h = 360 - (abs(h) / .pi) * 180
        }
        return (l, c, h)
    }

    init(x: Float, y: Float, z: Float) {
        let x = x / 100
        let y = y / 100
        let z = z / 100

        var r = x * 3.2406 + y * -1.5372 + z * -0.4986
        var g = x * -0.9689 + y * 1.8758 + z * 0.0415
        var b = x * 0.0557 + y * -0.2040 + z * 1.0570

        if r > 0.0031308 {
            r = 1.055 * pow(r, 0.41666667) - 0.055
        } else {
            r = 12.92 * r
        }

        if g > 0.0031308 {
            g = 1.055 * pow(g, 0.41666667) - 0.055
        } else {
            g = 12.92 * g
        }

        if b > 0.0031308 {
            b = 1.055 * pow(b, 0.41666667) - 0.055
        } else {
            b = 12.92 * b
        }

        self.init(r: r.positive, g: g.positive, b: b.positive)
    }

    init(l: Float, a: Float, b: Float) {
        var y = (l + 16) / 116
        var x = a / 500 + y
        var z = y - b / 200

        if pow(y, 3) > 0.008856 {
            y = pow(y, 3)
        } else {
            y = (y - 0.137931034) / 7.787
        }

        if pow(x, 3) > 0.008856 {
            x = pow(x, 3)
        } else {
            x = (x - 0.137931034) / 7.787
        }

        if pow(z, 3) > 0.008856 {
            z = pow(z, 3)
        } else {
            z = (z - 0.137931034) / 7.787
        }

        x = 95.047 * x
        y = 100.000 * y
        z = 108.883 * z

        self.init(x: x, y: y, z: z)
    }

    init(l: Float, c: Float, h: Float) {
        let a = cos(h * 0.01745329251) * c
        let b = sin(h * 0.01745329251) * c
        self.init(l: l, a: a, b: b)
    }
}
