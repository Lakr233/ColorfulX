//
//  ColorfulPreset.swift
//
//
//  Created by QAQ on 2023/12/3.
//

import ColorVector
import SwiftUI

public enum ColorfulPreset: String, CaseIterable {
    case sunrise
    case sunset
    case love
    case ocean
    case barbie
    case starry
    case jelly
    case lavandula
    case watermelon
    case dandelion
    case lemon
    case spring
    case summer
    case autumn
    case winter
    case neon
    case aurora

    case appleIntelligence

    case colorful

    public var colors: [Color] {
        switch self {
        case .sunrise: return [make(186, 143, 181), make(231, 157, 175), make(248, 181, 169), make(254, 227, 169)]
        case .sunset: return [make(233, 129, 28), make(244, 172, 86), make(169, 31, 43), make(208, 63, 29)]
        case .love: return [make(254, 116, 97), make(243, 8, 32), make(250, 193, 208), make(193, 123, 126)]
        case .ocean: return [make(224, 244, 233), make(128, 193, 184), make(14, 179, 171), make(3, 144, 150)]
        case .barbie: return [make(254, 143, 229), make(255, 126, 179), make(254, 144, 195), make(230, 96, 160)]
        case .starry: return [make(244, 245, 168), make(108, 137, 198), make(44, 59, 108), make(22, 30, 45)]
        case .jelly: return [make(54, 151, 174), make(19, 49, 75), make(178, 133, 193), make(237, 210, 233)]
        case .lavandula: return [make(164, 149, 211), make(190, 138, 198), make(67, 15, 129), make(168, 144, 181)]
        case .watermelon: return [make(203, 18, 25), make(255, 103, 112), make(233, 167, 80), make(162, 183, 4)]
        case .dandelion: return [make(227, 213, 186), make(240, 242, 230), make(181, 230, 220), make(104, 154, 141)]
        case .lemon: return [make(233, 227, 140), make(207, 217, 187), make(212, 231, 238), make(127, 186, 216)]
        case .spring: return [make(254, 109, 170), make(254, 169, 199), make(252, 250, 246), make(99, 147, 164)]
        case .summer: return [make(65, 71, 42), make(232, 222, 106), make(105, 129, 70), make(79, 100, 52)]
        case .autumn: return [make(251, 176, 57), make(239, 122, 51), make(231, 82, 44), make(189, 60, 43)]
        case .winter: return [make(190, 212, 240), make(129, 152, 205), make(196, 181, 215), make(243, 243, 243)]
        case .neon: return [make(22, 4, 74), make(240, 54, 248), make(79, 216, 248), make(74, 0, 217)]
        case .aurora: return [make(0, 209, 172), make(0, 150, 150), make(4, 76, 112), make(23, 38, 69)]
        case .appleIntelligence: return [
            make(239, 176, 76), make(233, 128, 86), make(234, 75, 107),
            make(230, 97, 165), make(223, 138, 233), make(192, 160, 245),
            make(100, 181, 245), make(126, 201, 238)
        ].map { ColorElement($0) }.map { $0.withAlphaComponent(.random(in: 0.25 ... 1.0)) }.map { Color($0) }
        case .colorful: return [#colorLiteral(red: 0.9586862922, green: 0.660125792, blue: 0.8447988033, alpha: 1), #colorLiteral(red: 0.8714533448, green: 0.723166883, blue: 0.9342088699, alpha: 1), #colorLiteral(red: 0.7458761334, green: 0.7851135731, blue: 0.9899476171, alpha: 1), #colorLiteral(red: 0.4398113191, green: 0.8953480721, blue: 0.9796616435, alpha: 1), #colorLiteral(red: 0.3484552801, green: 0.933657825, blue: 0.9058339596, alpha: 1), #colorLiteral(red: 0.5567936897, green: 0.9780793786, blue: 0.6893508434, alpha: 1)].map { .init($0.withAlphaComponent(0.5)) }
        }
    }

    public var hint: String {
        switch self {
        case .appleIntelligence: return "AI"
        default: return rawValue.capitalized
        }
    }

    private func make(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 255) -> Color {
        Color(ColorElement(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        ))
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }
}
