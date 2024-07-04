//
//  Uniforms.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import MetalKit

struct Uniforms {
    static let COLOR_SLOT = 8

    let pointCount: simd_int1

    let bias: simd_float1
    let power: simd_float1
    let noise: simd_float1

    let point0: simd_float2
    let point1: simd_float2
    let point2: simd_float2
    let point3: simd_float2
    let point4: simd_float2
    let point5: simd_float2
    let point6: simd_float2
    let point7: simd_float2

    let color0: simd_float4
    let color1: simd_float4
    let color2: simd_float4
    let color3: simd_float4
    let color4: simd_float4
    let color5: simd_float4
    let color6: simd_float4
    let color7: simd_float4
}
