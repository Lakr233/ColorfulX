//
//  ColorfulView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import SwiftUI

public struct ColorfulView: View {
    @Binding var color: [Color]
    @Binding var speed: Double
    @Binding var bias: Double
    @Binding var noise: Double
    @Binding var transitionSpeed: Double
    @Binding var frameLimit: Int
    @Binding var renderScale: Double

    let repeats: Bool

    /// Initialize the ColorfulView by wrapping around the AnimatedMulticolorGradientView.
    /// - Parameters:
    ///   - color: the color to be used in SwiftUI format
    ///   - speed: speed factor for the animation
    ///   - bias: controls the radiation of the colors, similar to blur factor
    ///   - noise: how many noise you want to use
    ///   - transitionSpeed: how long it tooks to animate when colors changed
    ///   - frameLimit: limit frames per seconds, rounded to vsync (only skip frames, not reschedule)
    ///   - renderScale: similar to view scale, you can set to a very low value if you do not use noise
    ///   - repeats: repeat colors to fill 8 slot for rendering, can be false if your number of colors will stay the same
    public init(
        color: Binding<[Color]>,
        speed: Binding<Double> = .constant(1.0),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(5),
        frameLimit: Binding<Int> = .constant(0),
        renderScale: Binding<Double> = .constant(1.0),
        repeats: Bool = true
    ) {
        _color = color
        _speed = speed
        _bias = bias
        _noise = noise
        _transitionSpeed = transitionSpeed
        _frameLimit = frameLimit
        _renderScale = renderScale

        self.repeats = repeats
    }

    var colorVectors: [ColorVector] {
        color.map { transform(color: $0) }
    }

    func transform(color: SwiftUI.Color) -> ColorVector {
        ColorVector(color.platformElement())
    }

    public var body: some View {
        AnimatedMulticolorGradientViewRepresentable(
            color: .init(get: { colorVectors }, set: { _ in }),
            speed: $speed,
            bias: $bias,
            noise: $noise,
            transitionSpeed: $transitionSpeed,
            frameLimit: $frameLimit,
            renderScale: $renderScale,
            repeats: repeats
        )
    }
}

private extension Color {
    func platformElement() -> ColorElement {
        if #available(iOS 14.0, macCatalyst 14.0, tvOS 14.0, macOS 11.0, visionOS 1.0, *) {
            ColorElement(self)
        } else {
            transform()
        }
    }

    @available(iOS 13.0, macCatalyst 13.0, tvOS 13.0, *)
    @available(macOS, unavailable)
    private func transform() -> ColorElement {
        // reset of the world supports UIKit (eg: iOS 13 + macCatalyst 13 + tvOS 13)
        let components = components()
        return ColorElement(
            red: components.r,
            green: components.g,
            blue: components.b,
            alpha: components.a
        )
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
            a = CGFloat(hexNumber & 0x0000_00FF) / 255
        }
        return (r, g, b, a)
    }
}

public extension ColorfulView {
    /// Initialize the ColorfulView by wrapping around the AnimatedMulticolorGradientView.
    /// - Parameters:
    ///   - color: the color to be used in SwiftUI format
    ///   - speed: speed factor for the animation
    ///   - bias: controls the radiation of the colors, similar to blur factor
    ///   - noise: how many noise you want to use
    ///   - transitionSpeed: how long it tooks to animate when colors changed
    ///   - frameLimit: limit frames per seconds, rounded to vsync (only skip frames, not reschedule)
    ///   - renderScale: similar to view scale, you can set to a very low value if you do not use noise
    ///   - repeats: repeat colors to fill 8 slot for rendering, can be false if your number of colors will stay the same
    init(
        color: [Color],
        speed: Binding<Double> = .constant(1.0),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(5),
        frameLimit: Binding<Int> = .constant(0),
        renderScale: Binding<Double> = .constant(1.0),
        repeats: Bool = true
    ) {
        let colorBinding = Binding<[Color]>(get: {
            color
        }, set: { _ in
            assertionFailure()
        })
        self.init(
            color: colorBinding,
            speed: speed,
            bias: bias,
            noise: noise,
            transitionSpeed: transitionSpeed,
            frameLimit: frameLimit,
            renderScale: renderScale,
            repeats: repeats
        )
    }

    /// Initialize the ColorfulView by wrapping around the AnimatedMulticolorGradientView.
    /// - Parameters:
    ///   - preset: the preset to be used, binding set will be omitted and reporting an error when debug
    ///   - speed: speed factor for the animation
    ///   - bias: controls the radiation of the colors, similar to blur factor
    ///   - noise: how many noise you want to use
    ///   - transitionSpeed: how long it tooks to animate when colors changed
    ///   - frameLimit: limit frames per seconds, rounded to vsync (only skip frames, not reschedule)
    ///   - renderScale: similar to view scale, you can set to a very low value if you do not use noise
    ///   - repeats: repeat colors to fill 8 slot for rendering, can be false if your number of colors will stay the same
    init(
        color: Binding<ColorfulPreset>,
        speed: Binding<Double> = .constant(1.0),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(5),
        frameLimit: Binding<Int> = .constant(0),
        renderScale: Binding<Double> = .constant(1.0),
        repeats: Bool = true
    ) {
        let colorBinding = Binding<[Color]>(get: {
            color.wrappedValue.colors.map { .init($0) }
        }, set: { _ in
            assertionFailure()
        })
        self.init(
            color: colorBinding,
            speed: speed,
            bias: bias,
            noise: noise,
            transitionSpeed: transitionSpeed,
            frameLimit: frameLimit,
            renderScale: renderScale,
            repeats: repeats
        )
    }

    /// Initialize the ColorfulView by wrapping around the AnimatedMulticolorGradientView.
    /// - Parameters:
    ///   - preset: the preset to be used
    ///   - speed: speed factor for the animation
    ///   - bias: controls the radiation of the colors, similar to blur factor
    ///   - noise: how many noise you want to use
    ///   - transitionSpeed: how long it tooks to animate when colors changed
    ///   - frameLimit: limit frames per seconds, rounded to vsync (only skip frames, not reschedule)
    ///   - renderScale: similar to view scale, you can set to a very low value if you do not use noise
    ///   - repeats: repeat colors to fill 8 slot for rendering, can be false if your number of colors will stay the same
    init(
        color: ColorfulPreset,
        speed: Binding<Double> = .constant(1.0),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(5),
        frameLimit: Binding<Int> = .constant(0),
        renderScale: Binding<Double> = .constant(1.0),
        repeats: Bool = true
    ) {
        self.init(
            color: .constant(color),
            speed: speed,
            bias: bias,
            noise: noise,
            transitionSpeed: transitionSpeed,
            frameLimit: frameLimit,
            renderScale: renderScale,
            repeats: repeats
        )
    }

    /// Initialize the ColorfulView by wrapping around the AnimatedMulticolorGradientView.
    /// - Parameters:
    ///   - preset: the preset to be used
    ///   - speed: speed factor for the animation
    ///   - bias: controls the radiation of the colors, similar to blur factor
    ///   - noise: how many noise you want to use
    ///   - transitionSpeed: how long it tooks to animate when colors changed
    ///   - frameLimit: limit frames per seconds, rounded to vsync (only skip frames, not reschedule)
    ///   - renderScale: similar to view scale, you can set to a very low value if you do not use noise
    ///   - repeats: repeat colors to fill 8 slot for rendering, can be false if your number of colors will stay the same
    init(
        color: ColorfulColors,
        speed: Binding<Double> = .constant(1.0),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(5),
        frameLimit: Binding<Int> = .constant(0),
        renderScale: Binding<Double> = .constant(1.0),
        repeats: Bool = true
    ) {
        let colorBinding = Binding<[Color]>(get: {
            color.colors.map { Color($0) }
        }, set: { _ in
            assertionFailure()
        })
        self.init(
            color: colorBinding,
            speed: speed,
            bias: bias,
            noise: noise,
            transitionSpeed: transitionSpeed,
            frameLimit: frameLimit,
            renderScale: renderScale,
            repeats: repeats
        )
    }
}
