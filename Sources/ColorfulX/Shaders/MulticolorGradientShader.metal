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

float2 hash23(float3 p3)
{
    p3 = fract(p3 * float3(443.897, 441.423, .0973));
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);
}

kernel void gradient(texture2d<float, access::write> output [[texture(4)]],
                     constant Uniforms& uniforms [[buffer(0)]],
                     uint2 gid [[thread_position_in_grid]])
{
    int width = output.get_width();
    int height = output.get_height();
    float2 noise = hash23(float3(float2(gid) / float2(width, width), 0));
    float2 uv = (float2(gid) + float2(sin(noise.x * 2 * M_PI_F), sin(noise.y * 2 * M_PI_F)) * uniforms.noise) / float2(width, width);
    
    float totalContribution = 0.0;
    float contribution[8];
    
    // Compute contributions
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        float2 pos = uniforms.points[i] * float2(1.0, float(height) / float(width));
        pos = uv - pos;
        float dist = length(pos);
        float c = 1.0 / (uniforms.bias + pow(dist, uniforms.power));
        contribution[i] = c;
        totalContribution += c;
    }
    
    // Contributions normalisation
    float3 col = float3(0, 0, 0);
    float inverseContribution = 1.0 / totalContribution;
    for (int i = 0; i < uniforms.pointCount; i++)
    {
        col += contribution[i] * inverseContribution * uniforms.colors[i];
    }
    
    float4 color = float4(col, 1.0);
    output.write(color, gid);
}
