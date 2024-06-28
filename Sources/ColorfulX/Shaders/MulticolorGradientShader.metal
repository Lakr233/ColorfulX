//
//  MeshGradient.metal
//  BlobToy
//
//  Created by Arthur Guibert on 23/03/2021.
//

#include <metal_stdlib>

using namespace metal;

typedef struct {
    int32_t pointCount;
    float bias;
    float power;
    float noise;
    float2 points[8];
    float3 colors[8];
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

float math_rad2deg(float radians) {
    return radians * 180.0 / M_PI_F;
}

float math_deg2rad(float degrees) {
    return degrees * M_PI_F / 180.0;
}

float math_lab_fn(float t) {
    float math_ref_v1 = 1.0 / 3.0;
    float math_ref_v2 = 4.0 / 29.0;
    float math_ref_v3 = 6.0 / 29.0;
    float math_ref_v4 = math_ref_v3 * math_ref_v3 * math_ref_v3;
    float math_ref_v5 = math_ref_v3 * math_ref_v3 * 3.0;
    if (t > math_ref_v4) { return pow(t, math_ref_v1); }
    return (t / math_ref_v5) + math_ref_v2;
}

float math_lab_rn_rev(float t) {
    float math_ref_v2 = 4.0 / 29.0;
    float math_ref_v3 = 6.0 / 29.0;
    float math_ref_v5 = math_ref_v3 * math_ref_v3 * 3.0;
    if (t > math_ref_v3) { return pow(t, 3.0); }
    return math_ref_v5 * (t - math_ref_v2);
}

float3 RGBToXYZ(float3 rgb) {
    float vr = (rgb.r > 0.03928) ? pow((rgb.r + 0.055) / 1.055, 2.4) : (rgb.r / 12.92);
    float vg = (rgb.g > 0.03928) ? pow((rgb.g + 0.055) / 1.055, 2.4) : (rgb.g / 12.92);
    float vb = (rgb.b > 0.03928) ? pow((rgb.b + 0.055) / 1.055, 2.4) : (rgb.b / 12.92);
    float vx = (0.4124564 * vr) + (0.3575761 * vg) + (0.1804375 * vb);
    float vy = (0.2126729 * vr) + (0.7151522 * vg) + (0.0721750 * vb);
    float vz = (0.0193339 * vr) + (0.1191920 * vg) + (0.9503041 * vb);
    float3 xyz = float3(vx * 100.0, vy * 100.0, vz * 100.0);
    return xyz;
}

kernel void computeColorFromRGBtoXYZ(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 rgb = input[id].color;
    float3 xyz = RGBToXYZ(rgb);
    output[id].color = xyz;
}

float3 XYZToLAB(float3 xyz) {
    float3 math_ref_v0 = float3(95.047, 100.000, 108.883);
    float vx = math_lab_fn(xyz.x / math_ref_v0.x);
    float vy = math_lab_fn(xyz.y / math_ref_v0.y);
    float vz = math_lab_fn(xyz.z / math_ref_v0.z);
    float3 lab = float3((116.0 * vy) - 16.0, 500.0 * (vx - vy), 200.0 * (vy - vz));
    return lab;
}

kernel void computeColorFromXYZtoLAB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 xyz = input[id].color;
    float3 lab = XYZToLAB(xyz);
    output[id].color = lab;
}

float3 LABToLCH(float3 lab) {
    float vc = sqrt((lab.y * lab.y) + (lab.z * lab.z));
    float vh = atan2(lab.z, lab.y);
    if (isnan(vh) || vc == 0) {
        vh = 0;
    } else if (vh >= 0) {
        vh = math_rad2deg(vh);
    } else {
        vh = 360.0 - math_rad2deg(abs(vh));
    }
    float3 lch = float3(lab.x, vc, vh);
    return lch;
}

kernel void computeColorFromLABtoLCH(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lab = input[id].color;
    float3 lch = LABToLCH(lab);
    output[id].color = lch;
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
    float a0 = lch.y * cos(math_deg2rad(lch.z));
    float b0 = lch.y * sin(math_deg2rad(lch.z));
    float3 lab = float3(lch.x, a0, b0);
    return lab;
}

kernel void computeColorFromLCHtoLAB(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lch = input[id].color;
    float3 lab = LCHToLAB(lch);
    output[id].color = lab;
}

float3 LABToXYZ(float3 lab) {
    float3 math_ref_v0 = float3(95.047, 100.000, 108.883);
    float vl = (lab.x + 16.0) / 116.0;
    float va = vl + (lab.y / 500.0);
    float vb = vl - (lab.z / 200.0);
    float x = math_lab_rn_rev(va) * math_ref_v0.x;
    float y = math_lab_rn_rev(vl) * math_ref_v0.y;
    float z = math_lab_rn_rev(vb) * math_ref_v0.z;
    float3 xyz = float3(x, y, z);
    return xyz;
}

kernel void computeColorFromLABtoXYZ(device Color* input [[buffer(0)]],
                                     device Color* output [[buffer(1)]],
                                     uint id [[thread_position_in_grid]]) {
    float3 lab = input[id].color;
    float3 xyz = LABToXYZ(lab);
    output[id].color = xyz;
}

float3 XYZToRGB(float3 xyz) {
    float vx = xyz.x / 100.0;
    float vy = xyz.y / 100.0;
    float vz = xyz.z / 100.0;
    float r = (3.2404542 * vx) - (1.5371385 * vy) - (0.4985314 * vz);
    float g = (-0.9692660 * vx) + (1.8760108 * vy) + (0.0415560 * vz);
    float b = (0.0556434 * vx) - (0.2040259 * vy) + (1.0572252 * vz);
    float k = 1.0 / 2.4;
    r = (r <= 0.00304) ? (12.92 * r) : (1.055 * pow(r, k) - 0.055);
    g = (g <= 0.00304) ? (12.92 * g) : (1.055 * pow(g, k) - 0.055);
    b = (b <= 0.00304) ? (12.92 * b) : (1.055 * pow(b, k) - 0.055);
    float3 rgb = float3(r, g, b);
    return clamp(rgb, 0.0, 1.0);
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
    
    float3 col = float3(0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float factor = contribution[i] * inverseContribution;
        col += uniforms.colors[i] * factor;
    }

    float4 color = float4(col, 1.0);
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
    
    // normalize the contribution for k average
    float3 col = float3(0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float factor = contribution[i] * inverseContribution;
        col += RGBToLCH(uniforms.colors[i]) * factor;
        /*
         example of how to do with LCH color
         average of   >          5         6         4         2         5 > sum = 22
         their factor >    0.1       0.2       0.2       0.1       0.5     > sum = 1
         average      >    0.1 * 5 + 0.2 * 6 + 0.2 * 4 + 0.1 * 2 + 0.5 * 5 > avg = 5.2
         */
    }
    
    // now back to rgb
    col = LCHToRGB(col);

    float4 color = float4(col, 1.0);
    output.write(color, gid);
}
