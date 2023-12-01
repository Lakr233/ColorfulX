//
//  ContentView.swift
//  ColofulApp
//
//  Created by QAQ on 2023/12/1.
//

import ColorfulX
import SwiftUI

struct ContentView: View {
    @State var preset: ColorfulPreset = .pinkAndPurple
    @State var speedFactor: Float = 1

    var body: some View {
        ZStack {
            ColorfulX(preset: preset, speedFactor: speedFactor)
            control
        }
        .frame(
            minWidth: 400, idealWidth: 600, maxWidth: .infinity,
            minHeight: 200, idealHeight: 400, maxHeight: .infinity,
            alignment: .center
        )
    }

    var control: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customization")
                .font(.system(.title3, design: .rounded, weight: .semibold))
            Divider()
            HStack {
                Text("Color Preset:")
                Spacer()
                Picker("", selection: $preset) {
                    ForEach(ColorfulPreset.allCases, id: \.self) { preset in
                        Text(preset.hint).tag(preset.rawValue)
                    }
                }
                .pickerStyle(.palette)
            }
            Divider()
            HStack {
                Text("Speed Control:")
                Spacer()
                Text("\(Int(speedFactor * 100))%")
            }
            Slider(value: $speedFactor, in: 0 ... 10, step: 0.01) { _ in
            }
            .foregroundStyle(.orange)
            Divider()
            Text("Made with love by @Lakr233")
        }
        .font(.system(.footnote, design: .rounded, weight: .semibold))
        .frame(width: 350)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 6)
                .foregroundStyle(.white)
                .opacity(0.95)
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

#Preview {
    ContentView()
}
