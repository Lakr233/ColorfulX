//
//  MetalProgram.swift
//
//
//  Created by 秋星桥 on 2024/8/7.
//

import Foundation
import MetalKit

private enum MetalProgram: String {
    case colorful = """
    #include <metal_stdlib>

    using namespace metal;

    #define M_PI 3.1415926535897932384626433832795
    #define COLOR_SOLT 8

    typedef struct
    {
        int32_t point_count;
        float bias;
        float power;
        float noise;
        float2 points[COLOR_SOLT];
        float4 colors[COLOR_SOLT];
    } Uniforms;

    float2 hash23(float3 p3)
    {
        p3 = fract(p3 * float3(443.897, 441.423, .0973));
        p3 += dot(p3, p3.yzx + 19.19);
        return fract((p3.xx + p3.yz) * p3.zy);
    }

    float3 LABToXYZ(float3 lab)
    {
        float l = lab.x;
        float a = lab.y;
        float b = lab.z;

        float y = (l + 16) / 116;
        float x = a / 500 + y;
        float z = y - b / 200;

        if (pow(y, 3) > 0.008856)
        {
            y = pow(y, 3);
        }
        else
        {
            y = (y - 0.137931034) / 7.787;
        }

        if (pow(x, 3) > 0.008856)
        {
            x = pow(x, 3);
        }
        else
        {
            x = (x - 0.137931034) / 7.787;
        }

        if (pow(z, 3) > 0.008856)
        {
            z = pow(z, 3);
        }
        else
        {
            z = (z - 0.137931034) / 7.787;
        }

        x = 95.047 * x;
        y = 100.000 * y;
        z = 108.883 * z;

        return float3(x, y, z);
    }

    float3 float3_xyz_to_rgb(float3 xyz)
    {
        float x = xyz.x / 100; // X from 0 to 95.047
        float y = xyz.y / 100; // Y from 0 to 100.000
        float z = xyz.z / 100; // Z from 0 to 108.883

        float r = x * 3.2406 + y * -1.5372 + z * -0.4986;
        float g = x * -0.9689 + y * 1.8758 + z * 0.0415;
        float b = x * 0.0557 + y * -0.2040 + z * 1.0570;

        if (r > 0.0031308)
        {
            r = 1.055 * (pow(r, 0.41666667)) - 0.055;
        }
        else
        {
            r = 12.92 * r;
        }

        if (g > 0.0031308)
        {
            g = 1.055 * (pow(g, 0.41666667)) - 0.055;
        }
        else
        {
            g = 12.92 * g;
        }

        if (b > 0.0031308)
        {
            b = 1.055 * (pow(b, 0.41666667)) - 0.055;
        }
        else
        {
            b = 12.92 * b;
        }

        return float3(r, g, b);
    }

    float3 float3_lab_to_rgb(float3 lab)
    {
        float3 xyz = LABToXYZ(lab);
        float3 rgb = float3_xyz_to_rgb(xyz);
        return rgb;
    }

    kernel void blend_colors(texture2d<float, access::write> output [[texture(4)]],
                             constant Uniforms &uniforms [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
    {
        int width = output.get_width();
        int height = output.get_height();
        float2 noise = hash23(float3(float2(gid) / float2(width, width), 0));
        float2 uv = (float2(gid) + float2(sin(noise.x * 2 * M_PI_F), sin(noise.y * 2 * M_PI_F)) * uniforms.noise) / float2(width, width);

        float contribution_total = 0.0;
        float contribution[COLOR_SOLT];

        for (int i = 0; i < uniforms.point_count; i++)
        {
            float2 pos = uniforms.points[i] * float2(1.0, float(height) / float(width));
            pos = uv - pos;
            float dist = length(pos);
            float c = 1.0 / (uniforms.bias + pow(dist, uniforms.power));
            contribution[i] = c;
            contribution_total += c;
        }

        float4 col = float4(0, 0, 0, 0);
        float contribution_factor = 1.0 / contribution_total;
        for (int i = 0; i < uniforms.point_count; i++)
        {
            float factor = contribution[i] * contribution_factor;
            col += uniforms.colors[i] * factor;
        }

        float alpha = clamp(col.w, 0.0, 1.0);
        float3 color_with_out_alpha = float3_lab_to_rgb(col.xyz);
        float3 premultiplied = color_with_out_alpha * alpha;
        float4 color = float4(premultiplied, alpha);

        output.write(clamp(color, 0.0, 1.0), gid);
    }
    """
}

public extension MTLDevice {
    func createColorfulLibrary() throws -> MTLLibrary {
        try makeLibrary(source: MetalProgram.colorful.rawValue, options: nil)
    }
}
