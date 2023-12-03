//
//  ContentView.swift
//  ColofulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

let defaultPreset: ColorfulPreset = .aurora

struct ContentView: View {
    let fps: Int = 60
    @State var preset: ColorfulPreset = defaultPreset
    @State var colors: [Color] = defaultPreset.colors
    @State var speed: Double = 1.0
    @State var duration: TimeInterval = 5

    var body: some View {
        NavigationSplitView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(ColorfulPreset.allCases, id: \.self) { each in
                        ColorfulView(colors: .constant(each.colors))
                            .frame(height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                Text(each.hint)
                                    .font(.system(.title3, design: .rounded, weight: .black))
                                    .foregroundStyle(.thickMaterial)
                            )
                            .onTapGesture {
                                preset = each
                                colors = each.colors
                            }
                    }
                }
                .padding(8)
            }
        } detail: {
            ColorfulView(fps: fps, colors: $colors, speedFactor: $speed, colorTransitionDuration: $duration)
                .overlay(controlPanel.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing))
                .navigationTitle("Colorful Preset - \(preset.hint)")
                .ignoresSafeArea()
        }
    }

    var controlPanel: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Render")
                Spacer()
                Text("\(fps)fps")
            }
            Divider()
            HStack {
                Text("Shader Colors")
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
            Divider()
            HStack {
                Text("Color Transition Duration")
                Spacer()
                Text("\(duration, specifier: "%.2f")s")
            }
            Slider(value: $duration, in: 0.0 ... 10.0, step: 0.1) { _ in
            }
            Divider()
            HStack {
                Text("Speed Factor")
                Spacer()
                Text("\(speed, specifier: "%.2f")")
            }
            Slider(value: $speed, in: 0.0 ... 10.0, step: 0.1) { _ in
            }
        }
        .frame(width: 250)
        .font(.system(.body, design: .rounded, weight: .semibold))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.thickMaterial)
        )
        .padding(6)
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
