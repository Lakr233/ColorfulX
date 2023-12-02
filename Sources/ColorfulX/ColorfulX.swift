//
//  ColorfulX.swift
//
//
//  Created by QAQ on 2023/12/1.
//

import Combine
import SwiftUI

public struct ColorfulX: View {
    @State private var animationAmount: CGFloat = .random(in: 0 ... 65535)

    public struct ColorSet: Hashable, Equatable, Identifiable {
        public var id: Int { hashValue }

        public let a: Color
        public let b: Color
        public let c: Color
        public let d: Color

        public init(_ a: Color, _ b: Color, _ c: Color, _ d: Color) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(a)
            hasher.combine(b)
            hasher.combine(c)
            hasher.combine(d)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
    }

    public let colors: ColorSet
    public let speedFactor: Float
    public let bias: Float
    public let noise: Float
    public let power: Float
    public let colorInterpolation: MulticolorGradient.ColorInterpolation
    public let fps: Int

    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init(
        colors: ColorSet,
        speedFactor: Float = 0.5,
        bias: Float = 0.001,
        noise: Float = 0,
        power: Float = 10,
        colorInterpolation: MulticolorGradient.ColorInterpolation = .hsb,
        fps: Int = 30
    ) {
        self.colors = colors
        self.speedFactor = speedFactor
        self.bias = bias
        self.noise = noise
        self.power = power
        self.colorInterpolation = colorInterpolation
        self.fps = fps

        let interval: TimeInterval = 1.0 / Double(fps)
        let timer = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
        self.timer = timer
    }

    public init(
        preset: ColorfulPreset,
        speedFactor: Float = 0.5,
        bias: Float = 0.001,
        noise: Float = 0,
        power: Float = 10,
        colorInterpolation: MulticolorGradient.ColorInterpolation = .hsb,
        fps: Int = 30
    ) {
        self.init(
            colors: preset.colors,
            speedFactor: speedFactor,
            bias: bias,
            noise: noise,
            power: power,
            colorInterpolation: colorInterpolation,
            fps: fps
        )
    }

    public var body: some View {
        MulticolorGradient {
            ColorStop(position: .init(
                x: 0 + sin(animationAmount),
                y: 0.5
            ), color: colors.a)
            ColorStop(position: .init(
                x: 0.5,
                y: 0 + sin(animationAmount)
            ), color: colors.b)
            ColorStop(position: .init(
                x: 0.5 + sin(animationAmount * 0.8) * 0.5,
                y: 0.5 + cos(animationAmount * 0.8) * 0.5
            ), color: colors.c)
            ColorStop(position: .init(
                x: 0.5 - sin(animationAmount) * 0.45,
                y: 0.5 + cos(animationAmount) * 0.5
            ), color: colors.d)
        }
        .bias(bias)
        .noise(noise)
        .power(power)
        .edgesIgnoringSafeArea(.all)
        .onReceive(timer) { _ in
            animationAmount += 0.01 * CGFloat(speedFactor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

public enum ColorfulPreset: String, CaseIterable {
    case sunrise
    case sunset
    case love
    case ocean
    case barbie
    case starry
    case jelly
    case lavandula
    case watermelon
    case dandelion
    case lemon
    case spring
    case summer
    case autumn
    case winter
    case neon
    case aurora

    public var colors: ColorfulX.ColorSet {
        switch self {
        case .sunrise: .init(c(186, 143, 181), c(231, 157, 175), c(248, 181, 169), c(254, 227, 169))
        case .sunset: .init(c(233, 129, 28), c(244, 172, 86), c(169, 31, 43), c(208, 63, 29))
        case .love: .init(c(254, 116, 97), c(243, 8, 32), c(250, 193, 208), c(193, 123, 126))
        case .ocean: .init(c(224, 244, 233), c(128, 193, 184), c(14, 179, 171), c(3, 144, 150))
        case .barbie: .init(c(254, 143, 229), c(255, 126, 179), c(254, 144, 195), c(230, 96, 160))
        case .starry: .init(c(244, 245, 168), c(108, 137, 198), c(44, 59, 108), c(22, 30, 45))
        case .jelly: .init(c(54, 151, 174), c(19, 49, 75), c(178, 133, 193), c(237, 210, 233))
        case .lavandula: .init(c(164, 149, 211), c(190, 138, 198), c(67, 15, 129), c(168, 144, 181))
        case .watermelon: .init(c(203, 18, 25), c(255, 103, 112), c(233, 167, 80), c(162, 183, 4))
        case .dandelion: .init(c(227, 213, 186), c(240, 242, 230), c(181, 230, 220), c(104, 154, 141))
        case .lemon: .init(c(233, 227, 140), c(207, 217, 187), c(212, 231, 238), c(127, 186, 216))
        case .spring: .init(c(254, 109, 170), c(254, 169, 199), c(252, 250, 246), c(99, 147, 164))
        case .summer: .init(c(65, 71, 42), c(232, 222, 106), c(105, 129, 70), c(79, 100, 52))
        case .autumn: .init(c(251, 176, 57), c(239, 122, 51), c(231, 82, 44), c(189, 60, 43))
        case .winter: .init(c(190, 212, 240), c(129, 152, 205), c(196, 181, 215), c(243, 243, 243))
        case .neon: .init(c(22, 4, 74), c(240, 54, 248), c(79, 216, 248), c(74, 0, 217))
        case .aurora: .init(c(0, 209, 172), c(0, 150, 150), c(4, 76, 112), c(23, 38, 69))
        }
    }

    public var hint: String {
        switch self {
        default: rawValue.capitalized
        }
    }

    private func c(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 255) -> Color {
        assert((0 ... 255).contains(r))
        assert((0 ... 255).contains(g))
        assert((0 ... 255).contains(b))
        assert((0 ... 255).contains(a))
        return Color(CoreColor(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        ))
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }
}
