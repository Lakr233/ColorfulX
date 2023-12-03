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

    public init(
        colors: Binding<[RGBColor]>,
        speedFactor: Binding<Double> = .constant(1),
        colorTransitionDuration: Binding<TimeInterval> = .constant(5),
        fps: Int = 60
    ) {
        _colors = colors
        _speedFactor = speedFactor
        _colorTransitionDuration = colorTransitionDuration

        view = AnimatedMulticolorGradientView(fps: fps)
    }
}

#if canImport(UIKit)
    import UIKit
    extension AnimatedMulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> AnimatedMulticolorGradientView {
            view.setColors(colors, interpolationEnabled: false)
            view.setSpeedFactor(speedFactor)
            view.setColorTransitionDuration(colorTransitionDuration)
            return view
        }

        public func updateUIView(_ uiView: AnimatedMulticolorGradientView, context _: Context) {
            uiView.setColors(colors, interpolationEnabled: colorTransitionDuration > 0)
            uiView.setSpeedFactor(speedFactor)
            uiView.setColorTransitionDuration(colorTransitionDuration)
        }
    }
#else
    #if canImport(AppKit)
        import AppKit
        extension AnimatedMulticolorGradientViewRepresentable: NSViewRepresentable {
            public func makeNSView(context _: Context) -> AnimatedMulticolorGradientView {
                view.setColors(colors, interpolationEnabled: false)
                view.setSpeedFactor(speedFactor)
                view.setColorTransitionDuration(colorTransitionDuration)
                return view
            }

            public func updateNSView(_ nsView: AnimatedMulticolorGradientView, context _: Context) {
                nsView.setColors(colors, interpolationEnabled: colorTransitionDuration > 0)
                nsView.setSpeedFactor(speedFactor)
                nsView.setColorTransitionDuration(colorTransitionDuration)
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
