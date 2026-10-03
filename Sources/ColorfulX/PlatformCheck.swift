//
//  PlatformCheck.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

import Foundation

#if !canImport(UIKit) && !canImport(AppKit)
    #error("Unsupported Platform")
#endif
