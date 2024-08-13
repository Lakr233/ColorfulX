//
//  AnimatedMulticolorGradientView+SwiftUI.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import SwiftUI

public struct AnimatedMulticolorGradientViewRepresentable {
    @Binding var color: [ColorVector]
    @Binding var speed: Double
    @Binding var bias: Double
    @Binding var noise: Double
    @Binding var transitionSpeed: Double
    @Binding var frameLimit: Int
    @Binding var renderScale: Double

    let repeatToFillColorSlots: Bool

    public init(
        color: Binding<[ColorVector]>,
        speed: Binding<Double> = .constant(1),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(3.25),
        frameLimit: Binding<Int> = .constant(0),
        renderScale: Binding<Double> = .constant(1),
        repeatToFillColorSlots: Bool = true
    ) {
        _color = color
        _speed = speed
        _bias = bias
        _noise = noise
        _transitionSpeed = transitionSpeed
        _frameLimit = frameLimit
        _renderScale = renderScale

        self.repeatToFillColorSlots = repeatToFillColorSlots
    }

    public func updatePropertyToView(_ view: AnimatedMulticolorGradientView) {
        view.frameLimit = frameLimit
        view.metalLink?.scaleFactor = renderScale

        view.setColors(
            color,
            interpolationEnabled: transitionSpeed > 0,
            repeatToFillColorSlots: repeatToFillColorSlots
        )
        view.speed = speed
        view.bias = bias
        view.noise = noise
        view.transitionSpeed = transitionSpeed
    }
}

#if canImport(UIKit)
    import UIKit

    extension AnimatedMulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> AnimatedMulticolorGradientView {
            let view = AnimatedMulticolorGradientView()
            updatePropertyToView(view)
            return view
        }

        public func updateUIView(_ uiView: AnimatedMulticolorGradientView, context _: Context) {
            updatePropertyToView(uiView)
        }
    }
#endif

#if !canImport(UIKit) && canImport(AppKit)
    import AppKit

    extension AnimatedMulticolorGradientViewRepresentable: NSViewRepresentable {
        public func makeNSView(context _: Context) -> AnimatedMulticolorGradientView {
            let view = AnimatedMulticolorGradientView()
            updatePropertyToView(view)
            return view
        }

        public func updateNSView(_ nsView: AnimatedMulticolorGradientView, context _: Context) {
            updatePropertyToView(nsView)
        }
    }
#endif
