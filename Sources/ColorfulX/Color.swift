//
//  Color.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import Foundation
import ColorVector

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
            Double(components[0]),
            Double(components[1]),
            Double(components[2]),
            Double(components[3])
        ), space: .rgb)
        if space == .rgb {
            self = rgbVector
        } else {
            self = rgbVector.color(in: space)
        }
    }
}
