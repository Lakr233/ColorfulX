//
//  ColorfulView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI

public struct ColorfulView: View {
    @Binding var colors: [Color]
    @Binding var speed: Double
    @Binding var noise: Float
    @Binding var transitionInterval: TimeInterval

    public init(
        colors: Binding<[Color]>,
        speed: Binding<Double> = .constant(1.0),
        noise: Binding<Float> = .constant(0),
        transitionInterval: Binding<TimeInterval> = .constant(5)
    ) {
        _colors = colors
        _speed = speed
        _noise = noise
        _transitionInterval = transitionInterval
    }

    public var body: some View {
        AnimatedMulticolorGradientViewRepresentable(
            color: .init(get: {
                colors.map { RGBColor(CoreColor($0)) }
            }, set: { _ in assertionFailure() }),
            speed: $speed,
            noise: $noise,
            transitionDuration: $transitionInterval
        )
    }
}
