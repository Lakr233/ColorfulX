//
//  Color.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import Foundation

#if canImport(CoreImage)
  import CoreImage
#endif

private struct RGBAComponents {
  let red: Double
  let green: Double
  let blue: Double
  let alpha: Double
}

public typealias ColorSpace = ColorVector.Space

#if canImport(UIKit)
  import UIKit

  public typealias ColorElement = UIColor
#endif

#if !canImport(UIKit) && canImport(AppKit)
  import AppKit

  public typealias ColorElement = NSColor
#endif

extension ColorVector {
  public init(_ color: ColorElement, usingSpace space: Space = .rgb) {
    guard let components = extractRGBAComponents(from: color) else {
      assertionFailure("Failed to normalize color components: \(color)")
      self.init(space: space)
      return
    }

    let clamped = RGBAComponents(
      red: clamp01(components.red),
      green: clamp01(components.green),
      blue: clamp01(components.blue),
      alpha: clamp01(components.alpha),
    )

    let rgbVector = ColorVector(
      v: .init(
        clamped.red * 255,
        clamped.green * 255,
        clamped.blue * 255,
        clamped.alpha,
      ), space: .rgb)
    if space == .rgb {
      self = rgbVector
    } else {
      self = rgbVector.color(in: space)
    }
  }
}

private func extractRGBAComponents(from color: ColorElement) -> RGBAComponents? {
  #if canImport(UIKit)
    return extractRGBAComponents(from: color.cgColor)
  #else
    let cgColor = color.cgColor
    if let components = extractRGBAComponents(from: cgColor) {
      return components
    }

    let candidateSpaces: [NSColorSpace] = [
      .extendedSRGB,
      .sRGB,
      .deviceRGB,
      .genericRGB,
    ]

    for space in candidateSpaces {
      if let converted = color.usingColorSpace(space) {
        let cgColor = converted.cgColor
        if let components = extractRGBAComponents(from: cgColor) {
          return components
        }
      }
    }

    #if canImport(CoreImage)
      if let ciColor = CIColor(color: color) {
        return RGBAComponents(
          red: Double(ciColor.red),
          green: Double(ciColor.green),
          blue: Double(ciColor.blue),
          alpha: Double(ciColor.alpha),
        )
      }
    #endif

    return nil
  #endif
}

private func extractRGBAComponents(from cgColor: CGColor) -> RGBAComponents? {
  guard let srgbSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
  let normalizedColor =
    cgColor.converted(
      to: srgbSpace,
      intent: .defaultIntent,
      options: nil,
    ) ?? cgColor

  guard let rawComponents = normalizedColor.components, !rawComponents.isEmpty else {
    return nil
  }

  if rawComponents.count >= 4 {
    return RGBAComponents(
      red: Double(rawComponents[0]),
      green: Double(rawComponents[1]),
      blue: Double(rawComponents[2]),
      alpha: Double(rawComponents[3]),
    )
  }

  if rawComponents.count == 3 {
    return RGBAComponents(
      red: Double(rawComponents[0]),
      green: Double(rawComponents[1]),
      blue: Double(rawComponents[2]),
      alpha: Double(normalizedColor.alpha),
    )
  }

  if rawComponents.count == 2 {
    let white = Double(rawComponents[0])
    return RGBAComponents(
      red: white,
      green: white,
      blue: white,
      alpha: Double(rawComponents[1]),
    )
  }

  if rawComponents.count == 1 {
    let white = Double(rawComponents[0])
    return RGBAComponents(
      red: white,
      green: white,
      blue: white,
      alpha: Double(normalizedColor.alpha),
    )
  }

  return nil
}

private func clamp01(_ value: Double) -> Double {
  if value < 0 { return 0 }
  if value > 1 { return 1 }
  return value
}
