//
//  ContentView.swift
//  ColofulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

struct ContentView: View {
    @State var preset: ColorfulPreset = .allCases.first!
    @State var speedFactor: Float = 1
    @State var bias: Float = 0.001
    @State var noise: Float = 0
    @State var power: Float = 10
    @State var colorInterpolation: MulticolorGradient.ColorInterpolation = .allCases.first!
    @State var fps: Int = 30

    var body: some View {
        ZStack {
            colorful
            control
        }
        .frame(
            minWidth: 400, idealWidth: 600, maxWidth: .infinity,
            minHeight: 200, idealHeight: 400, maxHeight: .infinity,
            alignment: .center
        )
    }

    var colorful: some View {
        ColorfulX(
            preset: preset,
            speedFactor: speedFactor,
            bias: bias,
            noise: noise,
            power: power,
            colorInterpolation: colorInterpolation,
            fps: fps
        )
    }

    var control: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                HStack {
                    Text("Color Preset:")
                    Spacer()
                    Picker("", selection: $preset) {
                        ForEach(ColorfulPreset.allCases, id: \.self) { preset in
                            Text(preset.hint).tag(preset.rawValue)
                        }
                    }
                    .pickerStyle(.automatic)
                }
                Divider()
            }
            Group {
                HStack {
                    Text("Color Interpolation:")
                    Spacer()
                    Picker("", selection: $colorInterpolation) {
                        ForEach(MulticolorGradient.ColorInterpolation.allCases, id: \.self) { preset in
                            Text(preset.rawValue.uppercased()).tag(preset.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Divider()
            }
            Group {
                HStack {
                    Text("Speed Control:")
                    Spacer()
                    Text(String(format: "x%.1f", speedFactor))
                        .monospaced()
                }
                Slider(value: $speedFactor, in: 0 ... 8, step: 0.1) { _ in
                }
                Divider()
            }
            Group {
                HStack {
                    Text("BIAS:")
                    Spacer()
                    Text(String(format: "%.4f", bias))
                        .monospaced()
                }
                Slider(value: $bias, in: 0 ... 0.005, step: 0.00005) { _ in
                }
                Divider()
            }
            Group {
                HStack {
                    Text("Noise:")
                    Spacer()
                    Text(String(format: "%.0f", noise))
                        .monospaced()
                }
                Slider(value: $noise, in: 0 ... 256, step: 1) { _ in
                }
                Divider()
            }
            Group {
                HStack {
                    Text("Power:")
                    Spacer()
                    Text(String(format: "%.0f", power))
                        .monospaced()
                }
                Slider(value: $power, in: 0 ... 32, step: 0.5) { _ in
                }
                Divider()
            }
        }
        .font(.system(.headline, design: .rounded))
        .frame(width: 350)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 6)
                .foregroundStyle(.windowBackground)
                .opacity(0.5)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 0)
        )
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottomLeading
        )
        .padding(12) // 18px - 6px
    }

    // https://apple.stackexchange.com/questions/399414/what-is-the-radius-of-the-windows-on-bigsur
    // As far as I can tell from analyzing a screenshot from a MacBook Pro 15 Inch: 18px
}
