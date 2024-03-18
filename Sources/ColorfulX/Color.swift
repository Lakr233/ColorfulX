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

private enum Math {
    static let v0: (x: Float, y: Float, z: Float) = (95.047, 100.000, 108.883)
    static let v1: Float = 1.0 / 3.0
    static let v2: Float = 4.0 / 29.0
    static let v3: Float = 6.0 / 29.0
    static let v4 = v3 * v3 * v3
    static let v5 = v3 * v3 * 3.0

    static func lab_fn(_ t: Float) -> Float {
        if t > v4 { return pow(t, v1) }
        return (t / v5) + v2
    }

    static func lab_fn_rev(_ t: Float) -> Float {
        if t > v3 { return pow(t, 3.0) }
        return v5 * (t - v2)
    }

    static func rad2deg(_ radians: Float) -> Float {
        radians * 180.0 / .pi
    }

    static func deg2rad(_ degrees: Float) -> Float {
        degrees * .pi / 180.0
    }
}

private extension Float {
    var positive: Float {
        if self < 0 { return 0 }
        return self
    }
}

extension RGBColor {
    var xyz: (x: Float, y: Float, z: Float) {
        let vr = (r > 0.03928) ? pow((r + 0.055) / 1.055, 2.4) : (r / 12.92)
        let vg = (g > 0.03928) ? pow((g + 0.055) / 1.055, 2.4) : (g / 12.92)
        let vb = (b > 0.03928) ? pow((b + 0.055) / 1.055, 2.4) : (b / 12.92)
        let vx = (0.4124564 * vr) + (0.3575761 * vg) + (0.1804375 * vb)
        let vy = (0.2126729 * vr) + (0.7151522 * vg) + (0.0721750 * vb)
        let vz = (0.0193339 * vr) + (0.1191920 * vg) + (0.9503041 * vb)
        return (vx * 100.0, vy * 100.0, vz * 100.0)
    }

    var lab: (l: Float, a: Float, b: Float) {
        let xyz = self.xyz
        let ref = Math.v0
        let vx = Math.lab_fn(xyz.x / ref.x)
        let vy = Math.lab_fn(xyz.y / ref.y)
        let vz = Math.lab_fn(xyz.z / ref.z)
        let l = (116.0 * vy) - 16.0
        let a = 500.0 * (vx - vy)
        let b = 200.0 * (vy - vz)
        return (l, a, b)
    }

    var lch: (l: Float, c: Float, h: Float) {
        let lab = self.lab
        let vc = sqrt((lab.a * lab.a) + (lab.b * lab.b))
        var vh = atan2(lab.b, lab.a)
        if vh.isNaN || vc.isZero {
            vh = 0.0
        } else if vh >= 0.0 {
            vh = Math.rad2deg(vh)
        } else {
            vh = 360.0 - Math.rad2deg(abs(vh))
        }
        return (lab.l, vc, vh)
    }

    init(x: Float, y: Float, z: Float) {
        let vx = x / 100
        let vy = y / 100.0
        let vz = z / 100.0

        var r = (3.2404542 * vx) - (1.5371385 * vy) - (0.4985314 * vz)
        var g = (-0.9692660 * vx) + (1.8760108 * vy) + (0.0415560 * vz)
        var b = (0.0556434 * vx) - (0.2040259 * vy) + (1.0572252 * vz)

        let k: Float = 1.0 / 2.4
        r = (r <= 0.00304) ? (12.92 * r) : (1.055 * pow(r, k) - 0.055)
        g = (g <= 0.00304) ? (12.92 * g) : (1.055 * pow(g, k) - 0.055)
        b = (b <= 0.00304) ? (12.92 * b) : (1.055 * pow(b, k) - 0.055)

        self.init(r: r.positive, g: g.positive, b: b.positive)
    }

    init(l: Float, a: Float, b: Float) {
        let ref = Math.v0
        let vl = (l + 16.0) / 116.0
        let va = vl + (a / 500.0)
        let vb = vl - (b / 200.0)
        let x = Math.lab_fn_rev(va) * ref.x
        let y = Math.lab_fn_rev(vl) * ref.y
        let z = Math.lab_fn_rev(vb) * ref.z
        self.init(x: x, y: y, z: z)
    }

    init(l: Float, c: Float, h: Float) {
        let a = c * cos(Math.deg2rad(h))
        let b = c * sin(Math.deg2rad(h))
        self.init(l: l, a: a, b: b)
    }
}

//  Test Color Convention
//
//  struct ContentView: View {
//      @State var rgbColor: RGBColor = .init(.orange)
//      var body: some View {
//          VStack(spacing: 8) {
//              HStack {
//                  Text("[RGB] r:\(rgbColor.r) g:\(rgbColor.g) b:\(rgbColor.b)")
//                  Spacer()
//                  Text("MMMM")
//                      .opacity(0)
//                      .background(Color(NSColor(red: CGFloat(rgbColor.r), green: CGFloat(rgbColor.g), blue: CGFloat(rgbColor.b), alpha: 1)))
//              }
//              .font(.system(.footnote, design: .monospaced, weight: .semibold))
//              let lch = rgbColor.lch
//              HStack {
//                  Text("[RGB -> LCH] l:\(lch.l) c:\(lch.c) h:\(lch.h)")
//                  Spacer()
//              }
//              .font(.system(.footnote, design: .monospaced, weight: .semibold))
//              let rgb = RGBColor(l: lch.l, c: lch.c, h: lch.h)
//              HStack {
//                  Text("[RGB -> LCH -> RGB] r:\(rgb.r) g:\(rgb.g) b:\(rgb.b)")
//                  Spacer()
//                  Text("MMMM")
//                      .opacity(0)
//                      .background(Color(NSColor(red: CGFloat(rgb.r), green: CGFloat(rgb.g), blue: CGFloat(rgb.b), alpha: 1)))
//              }
//              .font(.system(.footnote, design: .monospaced, weight: .semibold))
//              Divider()
//              Slider(value: .init(get: {
//                  rgbColor.r
//              }, set: { value in
//                  rgbColor.r = value
//              }), in: 0 ... 1, step: 0.01)
//              Slider(value: .init(get: {
//                  rgbColor.g
//              }, set: { value in
//                  rgbColor.g = value
//              }), in: 0 ... 1, step: 0.01)
//              Slider(value: .init(get: {
//                  rgbColor.b
//              }, set: { value in
//                  rgbColor.b = value
//              }), in: 0 ... 1, step: 0.01)
//          }
//          .navigationTitle("RGB/LCH DEMO")
//          .frame(width: 400)
//          .padding()
//      }
//  }
