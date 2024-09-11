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

    public init(parameters: MulticolorGradientView.Parameters) {
        self.init(parameters: .init(get: {
            parameters
        }, set: { _ in
            assertionFailure()
        }))
    }

    public var body: some View {
        MulticolorGradientViewRepresentable(parameters: $parameters)
    }
}

public struct MulticolorGradientViewRepresentable {
    @Binding var parameters: MulticolorGradientView.Parameters

    public init(parameters: Binding<MulticolorGradientView.Parameters>) {
        _parameters = parameters
    }

    public func updatePropertyToView(_ view: MulticolorGradientView) {
        view.parameters = parameters
    }
}

#if canImport(UIKit)
    import UIKit

    extension MulticolorGradientViewRepresentable: UIViewRepresentable {
        public func makeUIView(context _: Context) -> MulticolorGradientView {
            let view = MulticolorGradientView()
            updatePropertyToView(view)
            return view
        }

        public func updateUIView(_ view: MulticolorGradientView, context _: Context) {
            updatePropertyToView(view)
        }
    }
#else
    #if canImport(AppKit)
        import AppKit

        extension MulticolorGradientViewRepresentable: NSViewRepresentable {
            public func makeNSView(context _: Context) -> MulticolorGradientView {
                let view = MulticolorGradientView()
                updatePropertyToView(view)
                return view
            }

            public func updateNSView(_ view: MulticolorGradientView, context _: Context) {
                updatePropertyToView(view)
            }
        }
    #else
        #error("unsupported platform")
    #endif
#endif
