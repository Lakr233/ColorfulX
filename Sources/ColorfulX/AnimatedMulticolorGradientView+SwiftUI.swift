//
//  AnimatedMulticolorGradientView+SwiftUI.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI
import ColorVector

public struct AnimatedMulticolorGradientViewRepresentable {
    let view: AnimatedMulticolorGradientView

    @Binding var color: [ColorVector]
    @Binding var speed: Double
    @Binding var bias: Double
    @Binding var noise: Double
    @Binding var transitionSpeed: Double
    @Binding var isPaused: Bool

    public init(
        color: Binding<[ColorVector]>,
        speed: Binding<Double> = .constant(1),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(3.25),
        isPaused: Binding<Bool> = .constant(false),
        frameLimit: Int = 0,
        interpolationOption: MulticolorGradientView.InterpolationOption = .lab
    ) {
        _color = color
        _speed = speed
        _bias = bias
        _noise = noise
        _transitionSpeed = transitionSpeed
        _isPaused = isPaused

        view = AnimatedMulticolorGradientView(interpolationOption: interpolationOption)
        view.frameLimit = frameLimit
    }
}

#if canImport(UIKit)
    import UIKit

    extension AnimatedMulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> AnimatedMulticolorGradientView {
            view.setColors(color, interpolationEnabled: false)
            view.speed = speed
            view.transitionSpeed = transitionSpeed
            view.bias = bias
            view.noise = noise
            view.isPaused = isPaused
            return view
        }

        public func updateUIView(_ uiView: AnimatedMulticolorGradientView, context _: Context) {
            uiView.setColors(color, interpolationEnabled: transitionSpeed > 0)
            uiView.speed = speed
            uiView.bias = bias
            uiView.noise = noise
            uiView.transitionSpeed = transitionSpeed
            uiView.isPaused = isPaused
        }
    }
#else
    #if canImport(AppKit)
        import AppKit

        extension AnimatedMulticolorGradientViewRepresentable: NSViewRepresentable {
            public func makeNSView(context _: Context) -> AnimatedMulticolorGradientView {
                view.setColors(color, interpolationEnabled: false)
                view.speed = speed
                view.transitionSpeed = transitionSpeed
                view.bias = bias
                view.noise = noise
                return view
            }

            public func updateNSView(_ nsView: AnimatedMulticolorGradientView, context _: Context) {
                nsView.setColors(color, interpolationEnabled: transitionSpeed > 0)
                nsView.speed = speed
                nsView.bias = bias
                nsView.noise = noise
                nsView.transitionSpeed = transitionSpeed
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
