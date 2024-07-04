//
//  MeshGradient.metal
//  BlobToy
//
//  Created by Arthur Guibert on 23/03/2021.
//

#include <metal_stdlib>

using namespace metal;

#define M_PI 3.1415926535897932384626433832795

typedef struct {
    int32_t pointCount;
    float bias;
    float power;
    float noise;
    float2 points[8];
    float4 colors[8];
} Uniforms;

typedef struct {
    float3 color;
} Color;

float2 hash23(float3 p3)
{
    p3 = fract(p3 * float3(443.897, 441.423, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);
}

float3 RGBToXYZ(float3 rgb) {
    float r = rgb.r;
    float g = rgb.g;
    float b = rgb.b;
    
    if (r > 0.04045) {
        r = pow((r + 0.055) / 1.055, 2.4);
    } else {
        r = r / 12.92;
    }
    if (g > 0.04045) {
        g = pow((g + 0.055) / 1.055, 2.4);
    } else {
        g = g / 12.92;
    }
    if (b > 0.04045) {
        b = pow((b + 0.055) / 1.055, 2.4);
    } else {
        b = b / 12.92;
    }
    r *= 100;
    g *= 100;
    b *= 100;
    
    // Observer = 2°, Illuminant = D65
    float x = r * 0.4124 + g * 0.3576 + b * 0.1805;
    float y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    float z = r * 0.0193 + g * 0.1192 + b * 0.9505;
    
    return float3(x, y, z);
}

kernel void computeColorFromRGBtoXYZ(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 rgb = input[id].color;
    float3 xyz = RGBToXYZ(rgb);
    output[id].color = xyz;
}

float3 XYZToLAB(float3 xyz) {
    float vx = xyz.x / 95.047;
    float vy = xyz.y / 100.000;
    float vz = xyz.z / 108.883;

    if (vx > 0.008856) {
        vx = pow(vx, 0.333333333);
    } else {
        vx = 7.787 * vx + 0.137931034;
    }

    if (vy > 0.008856) {
        vy = pow(vy, 0.333333333);
    } else {
        vy = 7.787 * vy + 0.137931034;
    }

    if (vz > 0.008856) {
        vz = pow(vz, 0.333333333);
    } else {
        vz = 7.787 * vz + 0.137931034;
    }

    float l = (116.0 * vy) - 16.0;
    float a = 500.0 * (vx - vy);
    float b = 200.0 * (vy - vz);
    return float3(l, a, b);
}

kernel void computeColorFromXYZtoLAB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 xyz = input[id].color;
    float3 lab = XYZToLAB(xyz);
    output[id].color = lab;
}

float3 LABToLCH(float3 lab) {
    float l = lab.x;
    float a = lab.y;
    float b = lab.z;
    
    float c = sqrt(pow(a, 2) + pow(b, 2));

    float h = atan2(b, a);
    if (h > 0) {
        h = (h / M_PI) * 180;
    } else {
        h = 360 - (abs(h) / M_PI) * 180;
    }
    return float3(l, c, h);
}

kernel void computeColorFromLABtoLCH(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lab = input[id].color;
    float3 lch = LABToLCH(lab);
    output[id].color = lch;
}

float3 RGBToLAB(float3 rgb) {
    float3 xyz = RGBToXYZ(rgb);
    float3 lab = XYZToLAB(xyz);
    return lab;
}

kernel void computeColorFromRGBtoLAB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 rgb = input[id].color;
    float3 lab = RGBToLAB(rgb);
    output[id].color = lab;
}

float3 RGBToLCH(float3 rgb) {
    float3 xyz = RGBToXYZ(rgb);
    float3 lab = XYZToLAB(xyz);
    float3 lch = LABToLCH(lab);
    return lch;
}

kernel void computeColorFromRGBtoLCH(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 rgb = input[id].color;
    float3 lch = RGBToLCH(rgb);
    output[id].color = lch;
}

float3 LCHToLAB(float3 lch) {
    float l = lch.x;
    float c = lch.y;
    float h = lch.z;

    float a = cos(h * 0.01745329251) * c;
    float b = sin(h * 0.01745329251) * c;

    return float3(l, a, b);
}

kernel void computeColorFromLCHtoLAB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lch = input[id].color;
    float3 lab = LCHToLAB(lch);
    output[id].color = lab;
}

float3 LABToXYZ(float3 lab) {
    float l = lab.x;
    float a = lab.y;
    float b = lab.z;

    float y = (l + 16) / 116;
    float x = a / 500 + y;
    float z = y - b / 200;

    if (pow(y, 3) > 0.008856) {
        y = pow(y, 3);
    } else {
        y = (y - 0.137931034) / 7.787;
    }

    if (pow(x, 3) > 0.008856) {
        x = pow(x, 3);
    } else {
        x = (x - 0.137931034) / 7.787;
    }

    if (pow(z, 3) > 0.008856) {
        z = pow(z, 3);
    } else {
        z = (z - 0.137931034) / 7.787;
    }

    x = 95.047 * x;
    y = 100.000 * y;
    z = 108.883 * z;

    return float3(x, y, z);
}

kernel void computeColorFromLABtoXYZ(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lab = input[id].color;
    float3 xyz = LABToXYZ(lab);
    output[id].color = xyz;
}

float3 XYZToRGB(float3 xyz) {
    float x = xyz.x / 100; // X from 0 to 95.047
    float y = xyz.y / 100; // Y from 0 to 100.000
    float z = xyz.z / 100; // Z from 0 to 108.883

    float r = x * 3.2406 + y * -1.5372 + z * -0.4986;
    float g = x * -0.9689 + y * 1.8758 + z * 0.0415;
    float b = x * 0.0557 + y * -0.2040 + z * 1.0570;

    if (r > 0.0031308) {
        r = 1.055 * (pow(r, 0.41666667)) - 0.055;
    } else {
        r = 12.92 * r;
    }

    if (g > 0.0031308) {
        g = 1.055 * (pow(g, 0.41666667)) - 0.055;
    } else {
        g = 12.92 * g;
    }

    if (b > 0.0031308) {
        b = 1.055 * (pow(b, 0.41666667)) - 0.055;
    } else {
        b = 12.92 * b;
    }

    return float3(r, g, b);
}

kernel void computeColorFromXYZtoRGB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 xyz = input[id].color;
    float3 rgb = XYZToRGB(xyz);
    output[id].color = rgb;
}

float3 LCHToRGB(float3 lch) {
    float3 lab = LCHToLAB(lch);
    float3 xyz = LABToXYZ(lab);
    float3 rgb = XYZToRGB(xyz);
    return rgb;
}

kernel void computeColorFromLCHtoRGB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lch = input[id].color;
    float3 rgb = LCHToRGB(lch);
    output[id].color = rgb;
}

float3 LABToRGB(float3 lab) {
    float3 xyz = LABToXYZ(lab);
    float3 rgb = XYZToRGB(xyz);
    return rgb;
}

kernel void computeColorFromLABtoRGB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lab = input[id].color;
    float3 rgb = LABToRGB(lab);
    output[id].color = rgb;
}

kernel void gradientWithRGB(texture2d<float, access::write> output [[texture(4)]],
                     constant Uniforms& uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 noise = hash23(float3(float2(gid) / float2(width, width), 0));
    float2 uv = (float2(gid) + float2(sin(noise.x * 2 * M_PI_F), sin(noise.y * 2 * M_PI_F)) * uniforms.noise) / float2(width, width);
    
    float totalContribution = 0.0;
    float contribution[8];

    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float2 pos = uniforms.points[i] * float2(1.0, float(height) / float(width));
        pos = uv - pos;
        float dist = length(pos);
        float c = 1.0 / (uniforms.bias + pow(dist, uniforms.power));
        contribution[i] = c;
        totalContribution += c;
    }
    
    float4 color = float4(0, 0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float factor = contribution[i] * inverseContribution;
        color += uniforms.colors[i] * factor;
    }

    output.write(color, gid);
}

kernel void gradientWithXYZ(texture2d<float, access::write> output [[texture(4)]],
                     constant Uniforms& uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 noise = hash23(float3(float2(gid) / float2(width, width), 0));
    float2 uv = (float2(gid) + float2(sin(noise.x * 2 * M_PI_F), sin(noise.y * 2 * M_PI_F)) * uniforms.noise) / float2(width, width);
    
    float totalContribution = 0.0;
    float contribution[8];

    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float2 pos = uniforms.points[i] * float2(1.0, float(height) / float(width));
        pos = uv - pos;
        float dist = length(pos);
        float c = 1.0 / (uniforms.bias + pow(dist, uniforms.power));
        contribution[i] = c;
        totalContribution += c;
    }
    
    float4 col = float4(0, 0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float factor = contribution[i] * inverseContribution;
        float3 color_without_alpha = uniforms.colors[i].xyz;
        col += float4(RGBToXYZ(color_without_alpha), uniforms.colors[i].w) * factor;
    }

    float3 color_with_out_alpha = XYZToRGB(col.xyz);
    float4 color = float4(color_with_out_alpha, col.w);
    output.write(color, gid);
}

kernel void gradientWithLAB(texture2d<float, access::write> output [[texture(4)]],
                     constant Uniforms& uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 noise = hash23(float3(float2(gid) / float2(width, width), 0));
    float2 uv = (float2(gid) + float2(sin(noise.x * 2 * M_PI_F), sin(noise.y * 2 * M_PI_F)) * uniforms.noise) / float2(width, width);
    
    float totalContribution = 0.0;
    float contribution[8];

    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float2 pos = uniforms.points[i] * float2(1.0, float(height) / float(width));
        pos = uv - pos;
        float dist = length(pos);
        float c = 1.0 / (uniforms.bias + pow(dist, uniforms.power));
        contribution[i] = c;
        totalContribution += c;
    }
    
    float4 col = float4(0, 0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float factor = contribution[i] * inverseContribution;
        float3 color_without_alpha = uniforms.colors[i].xyz;
        col += float4(RGBToLAB(color_without_alpha), uniforms.colors[i].w) * factor;
    }

    float3 color_with_out_alpha = LABToRGB(col.xyz);
    float4 color = float4(color_with_out_alpha, col.w);
    output.write(color, gid);
}

kernel void gradientWithLCH(texture2d<float, access::write> output [[texture(4)]],
                     constant Uniforms& uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 noise = hash23(float3(float2(gid) / float2(width, width), 0));
    float2 uv = (float2(gid) + float2(sin(noise.x * 2 * M_PI_F), sin(noise.y * 2 * M_PI_F)) * uniforms.noise) / float2(width, width);
    
    float totalContribution = 0.0;
    float contribution[8];

    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float2 pos = uniforms.points[i] * float2(1.0, float(height) / float(width));
        pos = uv - pos;
        float dist = length(pos);
        float c = 1.0 / (uniforms.bias + pow(dist, uniforms.power));
        contribution[i] = c;
        totalContribution += c;
    }
    
    float4 col = float4(0, 0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float factor = contribution[i] * inverseContribution;
        float3 color_without_alpha = uniforms.colors[i].xyz;
        col += float4(RGBToLCH(color_without_alpha), uniforms.colors[i].w) * factor;
    }

    float3 color_with_out_alpha = LCHToRGB(col.xyz);
    float4 color = float4(color_with_out_alpha, col.w);
    output.write(color, gid);
}
