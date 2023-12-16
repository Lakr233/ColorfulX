//
//  AnimatedMulticolorGradientView+SwiftUI.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI

public struct AnimatedMulticolorGradientViewRepresentable {
    let view: AnimatedMulticolorGradientView

    @Binding var colors: [RGBColor]
    @Binding var speedFactor: Double
    @Binding var colorTransitionDuration: TimeInterval
    @Binding var noise: Float

    public init(
        colors: Binding<[RGBColor]>,
        speedFactor: Binding<Double> = .constant(1),
        colorTransitionDuration: Binding<TimeInterval> = .constant(5),
        noise: Binding<Float> = .constant(0)
    ) {
        _colors = colors
        _speedFactor = speedFactor
        _colorTransitionDuration = colorTransitionDuration
        _noise = noise

        view = AnimatedMulticolorGradientView()
    }
}

#if canImport(UIKit)
    import UIKit
    extension AnimatedMulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> AnimatedMulticolorGradientView {
            view.setColors(colors, interpolationEnabled: false)
            view.colorMoveSpeedFactor = speedFactor
            view.colorTransitionDuration = colorTransitionDuration
            view.colorNoise = noise
            return view
        }

        public func updateUIView(_ uiView: AnimatedMulticolorGradientView, context _: Context) {
            uiView.setColors(colors, interpolationEnabled: colorTransitionDuration > 0)
            uiView.colorMoveSpeedFactor = speedFactor
            uiView.colorTransitionDuration = colorTransitionDuration
            uiView.colorNoise = noise
        }
    }
#else
    #if canImport(AppKit)
        import AppKit
        extension AnimatedMulticolorGradientViewRepresentable: NSViewRepresentable {
            public func makeNSView(context _: Context) -> AnimatedMulticolorGradientView {
                view.setColors(colors, interpolationEnabled: false)
                view.colorMoveSpeedFactor = speedFactor
                view.colorTransitionDuration = colorTransitionDuration
                view.colorNoise = noise
                return view
            }

            public func updateNSView(_ nsView: AnimatedMulticolorGradientView, context _: Context) {
                nsView.setColors(colors, interpolationEnabled: colorTransitionDuration > 0)
                nsView.colorMoveSpeedFactor = speedFactor
                nsView.colorTransitionDuration = colorTransitionDuration
                nsView.colorNoise = noise
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
