//
//  CALayerAnimationsDisablingDelegate.swift
//  ColorfulX
//
//  Created by 秋星桥 on 2024/8/16.
//

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(AppKit)
    import AppKit
#endif

class CALayerAnimationsDisablingDelegate: NSObject, CALayerDelegate {
    static let shared = CALayerAnimationsDisablingDelegate()
    private let null = NSNull()

    func action(for _: CALayer, forKey _: String) -> CAAction? {
        null
    }
}
