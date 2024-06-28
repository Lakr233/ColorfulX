//
//  ContentView.swift
//  ColorfulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

let defaultPreset: ColorfulPreset = .aurora

struct ContentView: View {
    @AppStorage("preset") var preset: ColorfulPreset = defaultPreset
    @State var colors: [Color] = defaultPreset.colors
    @AppStorage("speed") var speed: Double = 1.0
    @AppStorage("bias") var bias: Double = 0.01
    @AppStorage("noise") var noise: Double = 1
    @AppStorage("duration") var duration: TimeInterval = 3.5
    @AppStorage("interpolationOption") var interpolationOption: MulticolorGradientView.InterpolationOption = .lab

    var body: some View {
        ZStack {
            ForEach([interpolationOption.rawValue], id: \.self) { _ in
                ColorfulView(
                    color: $colors,
                    speed: $speed,
                    bias: $bias,
                    noise: $noise,
                    transitionInterval: $duration,
                    interpolationOption: interpolationOption
                )
                .ignoresSafeArea()
                .transition(.opacity)
            }
            .animation(.interactiveSpring, value: interpolationOption.rawValue)
            VStack {
                controlPanel
                #if os(tvOS)
                    Button {
                        preset = ColorfulPreset.allCases.randomElement()!
                    } label: {
                        Image(systemName: "wind")
                    }
                #endif
            }

            Text("Made with love by @Lakr233")
                .foregroundStyle(.thinMaterial)
            #if os(macOS)
                .font(.system(size: 8, weight: .semibold, design: .rounded))
            #else
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            #endif
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding()
        }
        .onAppear { colors = preset.colors }
        .onChange(of: preset) { colors = $0.colors }
    }

    @ViewBuilder
    var presetPicker: some View {
        HStack {
            #if os(tvOS)
                Text("\(preset.hint)")
            #else
                Text("Preset")
                Picker("", selection: $preset) {
                    ForEach(ColorfulPreset.allCases, id: \.self) { preset in
                        Text(preset.hint).tag(preset)
                    }
                }
                .frame(width: 128)
            #endif
            Spacer()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(preset.colors, id: \.self) { color in
                        Text("8")
                            .opacity(0)
                            .overlay(Circle().foregroundColor(color))
                    }
                }
            }
            .flipsForRightToLeftLayoutDirection(true)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    @ViewBuilder
    var speedPicker: some View {
        HStack {
            Text("Speed")
            Spacer()
            Text("\(speed, specifier: "%.1f")")
        }
        #if !os(tvOS)
            Slider(value: $speed, in: 0.0 ... 10.0, step: 0.1) { _ in
            }
        #endif
    }

    @ViewBuilder
    var biasPicker: some View {
        HStack {
            Text("BIAS")
            Spacer()
            Text("\(bias, specifier: "%.5f")")
        }
        #if !os(tvOS)
            Slider(value: $bias, in: 0.00001 ... 0.01, step: 0.00001) { _ in
            }
        #endif
    }

    @ViewBuilder
    var noisePicker: some View {
        HStack {
            Text("Noise")
            Spacer()
            Text("\(noise, specifier: "%.2f")")
        }
        #if !os(tvOS)
            Slider(value: $noise, in: 0 ... 64, step: 1) { _ in
            }
        #endif
    }

    @ViewBuilder
    var transitionPicker: some View {
        HStack {
            Text("Transition")
            Spacer()
            Text("\(duration, specifier: "%.2f")s")
        }
        #if !os(tvOS)
            Slider(value: $duration, in: 0.0 ... 10.0, step: 0.1) { _ in
            }
        #endif
    }

    @ViewBuilder
    var interpolationPicker: some View {
        Picker("Interpolation Program", selection: $interpolationOption) {
            ForEach(MulticolorGradientView.InterpolationOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
    }

    var controlPanel: some View {
        VStack(spacing: 8) {
            presetPicker
            Divider()
            speedPicker
            Divider()
            biasPicker
            Divider()
            noisePicker
            Divider()
            transitionPicker
            Divider()
            interpolationPicker
        }
        .frame(width: 320)
        #if os(macOS)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
        #else
            .font(.system(size: 16, weight: .semibold, design: .rounded))
        #endif
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.thickMaterial)
            )
            .padding(6)
        #if os(visionOS)
            .padding(32)
        #endif
    }
}

struct StaticView: View {
    var body: some View {
        MulticolorGradient(
            parameters: .constant(.init(
                points: [
                    .init(color: .init(.init(Color.red)), position: .init(x: 0, y: 0)),
                    .init(color: .init(.init(Color.blue)), position: .init(x: 1, y: 0)),
                    .init(color: .init(.init(Color.green)), position: .init(x: 0, y: 1)),
                    .init(color: .init(.init(Color.yellow)), position: .init(x: 1, y: 1)),
                ],
                bias: 0.01,
                power: 4,
                noise: 32
            )))
    }
}
