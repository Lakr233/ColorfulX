//
//  MetalView.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

import Foundation

#if canImport(UIKit)
    public typealias MetalView = UIMetalView
#endif

#if !canImport(UIKit) && canImport(AppKit)
    public typealias MetalView = NSMetalView
#endif
