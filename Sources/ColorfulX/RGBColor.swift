//
//  RGBColor.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public struct RGBColor: Equatable {
    public let r: Float
    public let g: Float
    public let b: Float

    public init(r: Float, g: Float, b: Float) {
        self.r = r
        self.g = g
        self.b = b
    }
}

#if canImport(UIKit)
    import UIKit
    public typealias CoreColor = UIColor
#else
    #if canImport(AppKit)
        import AppKit
        public typealias CoreColor = NSColor
    #else
        #error("unsupported platform")
    #endif
#endif

public extension RGBColor {
    var coreColor: CoreColor {
        CoreColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
    }

    init(_ color: CoreColor) {
        guard let colorspaceSRGB = CGColorSpace(name: CGColorSpace.sRGB),
              let cgColor = color.cgColor.converted(
                  to: colorspaceSRGB,
                  intent: .defaultIntent,
                  options: nil
              )
        else {
            assertionFailure()
            self.init(r: 0, g: 0, b: 0)
            return
        }
        self.init(
            r: Float(cgColor.components?[0] ?? 0),
            g: Float(cgColor.components?[1] ?? 0),
            b: Float(cgColor.components?[2] ?? 0)
        )
    }
}
