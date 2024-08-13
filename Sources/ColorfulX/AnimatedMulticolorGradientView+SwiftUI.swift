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

    let frameLimit: Int
    
    public init(
        color: Binding<[ColorVector]>,
        speed: Binding<Double> = .constant(1),
        bias: Binding<Double> = .constant(0.01),
        noise: Binding<Double> = .constant(0),
        transitionSpeed: Binding<Double> = .constant(3.25),
        frameLimit: Int = 0
    ) {
        _color = color
        _speed = speed
        _bias = bias
        _noise = noise
        _transitionSpeed = transitionSpeed
        
        self.frameLimit = frameLimit
    }
    
    public func updatePropertyToView(_ view: AnimatedMulticolorGradientView) {
        view.setColors(color, interpolationEnabled: transitionSpeed > 0)
        view.speed = speed
        view.bias = bias
        view.noise = noise
        view.transitionSpeed = transitionSpeed
    }
}

#if canImport(UIKit)
    import UIKit

    extension AnimatedMulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context: Context) -> AnimatedMulticolorGradientView {
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
        public func makeNSView(context: Context) -> AnimatedMulticolorGradientView {
            let view = AnimatedMulticolorGradientView()
            updatePropertyToView(view)
            return view
        }

        public func updateNSView(_ nsView: AnimatedMulticolorGradientView, context _: Context) {
            updatePropertyToView(nsView)
        }
    }
#endif
