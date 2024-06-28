//
//  ShaderLibrary.swift
//
//
//  Created by 秋星桥 on 2024/6/28.
//

import Foundation
import MetalKit

public extension MTLDevice {
    func createColorfulLibrary() throws -> MTLLibrary {
        try makeDefaultLibrary(bundle: Bundle.module)
    }
}
