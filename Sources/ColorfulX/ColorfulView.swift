//
//  ColorfulView.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI

public struct ColorfulView: View {
    @Binding var color: [Color]
    @Binding var speed: Double
    @Binding var noise: Double
    @Binding var transitionInterval: TimeInterval

    @State var isPaused: Bool = false
    @Environment(\.scenePhase) var scenePhase

    let frameLimit: Int

    public init(
        color: Binding<[Color]>,
        speed: Binding<Double> = .constant(1.0),
        noise: Binding<Double> = .constant(0),
        transitionInterval: Binding<TimeInterval> = .constant(5),
        frameLimit: Int = 0
    ) {
        _color = color
        _speed = speed
        _noise = noise
        _transitionInterval = transitionInterval
        self.frameLimit = frameLimit
    }

    public var body: some View {
        AnimatedMulticolorGradientViewRepresentable(
            color: .init(get: {
                color.map { RGBColor(CoreColor($0)) }
            }, set: { _ in assertionFailure() }),
            speed: $speed,
            noise: $noise,
            transitionDuration: $transitionInterval,
            isPaused: $isPaused,
            frameLimit: frameLimit
        )
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                isPaused = false
            } else {
                isPaused = true
            }
        }
    }
}
