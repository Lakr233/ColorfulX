//
//  MulticolorGradientView+SwiftUI.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import SwiftUI

public struct MulticolorGradient: View {
    @Binding var parameters: MulticolorGradientView.Parameters

    public init(parameters: Binding<MulticolorGradientView.Parameters>) {
        _parameters = parameters
    }

    public var body: some View {
        MulticolorGradientViewRepresentable(parameters: $parameters)
    }
}

public struct MulticolorGradientViewRepresentable {
    let view = MulticolorGradientView()
    @Binding var parameters: MulticolorGradientView.Parameters

    public init(parameters: Binding<MulticolorGradientView.Parameters>) {
        _parameters = parameters
    }
}

#if canImport(UIKit)
    import UIKit

    extension MulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> MulticolorGradientView {
            view.parameters = parameters
            return view
        }

        public func updateUIView(_: MulticolorGradientView, context _: Context) {
            view.parameters = parameters
        }
    }
#else
    #if canImport(AppKit)
        import AppKit

        extension MulticolorGradientViewRepresentable: NSViewRepresentable {
            public func makeNSView(context _: Context) -> MulticolorGradientView {
                view.parameters = parameters
                return view
            }

            public func updateNSView(_: MulticolorGradientView, context _: Context) {
                view.parameters = parameters
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
