//
//  Color.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import Foundation

public typealias ColorSpace = ColorVector.Space

#if canImport(UIKit)
    import UIKit

    public typealias ColorElement = UIColor
#else
    #if canImport(AppKit)
        import AppKit

        public typealias ColorElement = NSColor
    #else
        #error("unsupported platform")
    #endif
#endif

extension ColorVector {
    init(_ color: ColorElement, usingSpace space: Space = .rgb) {
        let cgColor = color.cgColor
        let color = cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .defaultIntent,
            options: nil
        )
        guard let components = color?.components else {
            assertionFailure()
            self.init(space: space)
            return
        }
        let rgbVector = ColorVector(v: .init(
            Double(components[0] * 255),
            Double(components[1] * 255),
            Double(components[2] * 255),
            Double(components[3] * 255)
        ), space: .rgb)
        if space == .rgb {
            self = rgbVector
        } else {
            self = rgbVector.color(in: space)
        }
    }
}
