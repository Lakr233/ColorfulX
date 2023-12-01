//
//  ColorfulX.swift
//
//
//  Created by QAQ on 2023/12/1.
//

import SwiftUI

public struct ColorfulX: View {
    @State private var animationAmount: CGFloat = 0.0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    public struct ColorSet {
        public let a: Color
        public let b: Color
        public let c: Color

        public init(_ a: Color, _ b: Color, _ c: Color) {
            self.a = a
            self.b = b
            self.c = c
        }
    }

    public let colors: ColorSet
    public let speedFactor: Float
    public let bias: Float
    public let noise: Float
    public let power: Float
    public let colorInterpolation: MulticolorGradient.ColorInterpolation

    public init(
        colors: ColorSet,
        speedFactor: Float = 1,
        bias: Float = 0.001,
        noise: Float = 128,
        power: Float = 8,
        colorInterpolation: MulticolorGradient.ColorInterpolation = .hsb
    ) {
        self.colors = colors
        self.speedFactor = speedFactor
        self.bias = bias
        self.noise = noise
        self.power = power
        self.colorInterpolation = colorInterpolation
    }

    public init(
        preset: ColorfulPreset,
        speedFactor: Float = 1,
        bias: Float = 0.001,
        noise: Float = 128,
        power: Float = 8,
        colorInterpolation: MulticolorGradient.ColorInterpolation = .hsb
    ) {
        self.init(
            colors: preset.colors,
            speedFactor: speedFactor,
            bias: bias,
            noise: noise,
            power: power,
            colorInterpolation: colorInterpolation
        )
    }

    public var body: some View {
        MulticolorGradient {
            ColorStop(position: .init(
                x: 0 + sin(animationAmount),
                y: 0.5
            ), color: colors.a)
            ColorStop(position: .init(
                x: 0.5 + sin(animationAmount * 0.8) * 0.5,
                y: 0.5 + cos(animationAmount * 0.8) * 0.5
            ), color: colors.b)
            ColorStop(position: .init(
                x: 0.5 - sin(animationAmount) * 0.45,
                y: 0.5 + cos(animationAmount) * 0.5
            ), color: colors.c)
        }
        .bias(bias)
        .noise(noise)
        .power(power)
        .edgesIgnoringSafeArea(.all)
        .onReceive(timer) { _ in
            animationAmount += 0.02 * CGFloat(speedFactor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

public enum ColorfulPreset: String, CaseIterable {
    case pinkAndPurple
    case blueAndGreen

    public var colors: ColorfulX.ColorSet {
        switch self {
        case .pinkAndPurple: .init(
                Color(#colorLiteral(red: 0.9586862922, green: 0.660125792, blue: 0.8447988033, alpha: 1)),
                Color(#colorLiteral(red: 0.8714533448, green: 0.723166883, blue: 0.9342088699, alpha: 1)),
                Color(#colorLiteral(red: 0.7458761334, green: 0.7851135731, blue: 0.9899476171, alpha: 1))
            )
        case .blueAndGreen: .init(
                Color(#colorLiteral(red: 0.4398113191, green: 0.8953480721, blue: 0.9796616435, alpha: 1)),
                Color(#colorLiteral(red: 0.3484552801, green: 0.933657825, blue: 0.9058339596, alpha: 1)),
                Color(#colorLiteral(red: 0.5567936897, green: 0.9780793786, blue: 0.6893508434, alpha: 1))
            )
        }
    }

    public var hint: String {
        switch self {
        case .pinkAndPurple: "Pink & Purple"
        case .blueAndGreen: "Blue & Green"
        }
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
