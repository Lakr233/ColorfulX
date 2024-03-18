//
//  AnimatedMulticolorGradientView+SwiftUI.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI

public struct AnimatedMulticolorGradientViewRepresentable {
    let view: AnimatedMulticolorGradientView

    @Binding var color: [RGBColor]
    @Binding var speed: Double
    @Binding var noise: Double
    @Binding var transitionDuration: TimeInterval
    @Binding var isPaused: Bool

    public init(
        color: Binding<[RGBColor]>,
        speed: Binding<Double> = .constant(1),
        noise: Binding<Double> = .constant(0),
        transitionDuration: Binding<TimeInterval> = .constant(3.25),
        isPaused: Binding<Bool> = .constant(false),
        frameLimit: Int = 0
    ) {
        _color = color
        _speed = speed
        _noise = noise
        _transitionDuration = transitionDuration
        _isPaused = isPaused

        view = AnimatedMulticolorGradientView()
        view.frameLimit = frameLimit
    }
}

#if canImport(UIKit)
    import UIKit

    extension AnimatedMulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> AnimatedMulticolorGradientView {
            view.setColors(color, interpolationEnabled: false)
            view.speed = speed
            view.transitionDuration = transitionDuration
            view.noise = noise
            view.isPaused = isPaused
            return view
        }

        public func updateUIView(_ uiView: AnimatedMulticolorGradientView, context _: Context) {
            uiView.setColors(color, interpolationEnabled: transitionDuration > 0)
            uiView.speed = speed
            uiView.noise = noise
            uiView.transitionDuration = transitionDuration
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
                view.transitionDuration = transitionDuration
                view.noise = noise
                return view
            }

            public func updateNSView(_ nsView: AnimatedMulticolorGradientView, context _: Context) {
                nsView.setColors(color, interpolationEnabled: transitionDuration > 0)
                nsView.speed = speed
                nsView.noise = noise
                nsView.transitionDuration = transitionDuration
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
