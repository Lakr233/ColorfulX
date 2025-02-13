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
    @AppStorage("speed") var speed: Double = 1.0
    @AppStorage("bias") var bias: Double = 0.01
    @AppStorage("noise") var noise: Double = 1
    @AppStorage("duration") var duration: TimeInterval = 3.5
    @AppStorage("scale") var scale: Double = 1
    @AppStorage("frame") var frame: Int = 60

    @State var controlPanelVisible: Bool = true

    var body: some View {
        ZStack {
            ColorfulView(
                color: $preset,
                speed: $speed,
                bias: $bias,
                noise: $noise,
                transitionSpeed: $duration,
                frameLimit: $frame,
                renderScale: $scale
            )
            .background(ChessboardView().opacity(0.25))
            .ignoresSafeArea()
            VStack {
                controlPanel
                    .opacity(controlPanelVisible ? 1 : 0)
                    .animation(.spring, value: controlPanelVisible)
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
                .onTapGesture { controlPanelVisible.toggle() }
            #else
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            #endif
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding()
        }
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
                            .overlay(Circle().foregroundColor(.init(color)))
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
        #if os(iOS)
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
        #if os(iOS)
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
        #if os(iOS)
            Slider(value: $noise, in: 0 ... 64, step: 1) { _ in
            }
        #endif
    }

    @ViewBuilder
    var transitionPicker: some View {
        HStack {
            Text("Transition Speed")
            Spacer()
            Text("\(duration, specifier: "%.2f")")
        }
        #if os(iOS)
            Slider(value: $duration, in: 0.0 ... 10.0, step: 0.1) { _ in
            }
        #endif
    }

    @ViewBuilder
    var framePicker: some View {
        HStack {
            Text("Frame Limit")
            Spacer()
            Text("\(frame)")
        }
        #if os(iOS)
            Picker("", selection: $frame) {
                ForEach([0, 15, 30, 60, 120], id: \.self) { frame in
                    Text("\(frame)").tag(frame)
                }
            }
            .pickerStyle(.segmented)
        #endif
    }

    @ViewBuilder
    var scalePicker: some View {
        HStack {
            Text("Scale")
            Spacer()
            Text("\(scale, specifier: "%.4f")")
        }
        #if os(iOS)
            Slider(value: $scale, in: 0.001 ... 2.0, step: 0.001) { _ in
            }
        #endif
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
            scalePicker
            Divider()
            framePicker
        }
        .frame(width: 328)
        #if os(macOS)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
        #else
            .font(.system(size: 16, weight: .semibold, design: .rounded))
        #endif
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.regularMaterial)
            )
            .padding(6)
        #if os(visionOS)
            .padding(32)
        #endif
    }
}
