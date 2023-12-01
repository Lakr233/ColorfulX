//
//  MirrorAnimation.swift
//
//
//  Created by Arthur Guibert on 06/11/2022.
//

import Foundation

/// Animation paramaters that mirrors the one in SwiftUI
struct MirrorAnimation {
    var duration: TimeInterval
    var delay: TimeInterval
    struct RepeatParameters {
        let count: Int?
        let auroreverses: Bool
    }

    var repeatAnimation: RepeatParameters?
}

extension MirrorAnimation {
    static func parse(mirror: Mirror) -> MirrorAnimation {
        let labels = mirror.children.map(\.label)
        var animation = MirrorAnimation(duration: 0.0, delay: 0.0, repeatAnimation: nil)
        switch labels {
        case ["duration", "curve"]:
            animation.duration = animationDuration(from: mirror) ?? 0.0
        case ["animation", "speed"]: break
        case ["animation", "delay"]:
            let params = animationDurationAndDelay(from: mirror)
            animation.duration = params.duration ?? 0.0
            animation.delay = params.delay ?? 0.0
        case ["animation", "repeatCount", "autoreverses"]:
            let params = animationDurationAndRepeat(from: mirror)
            animation.duration = params.duration ?? 0.0
            animation.repeatAnimation = .init(count: params.repeatCount, auroreverses: params.autoreverses ?? true)
        default:
            break
        }
        return animation
    }

    private static func animationDuration(from mirror: Mirror) -> Double? {
        for c in mirror.children {
            switch c.label {
            case "duration": return c.value as? Double
            default: return nil
            }
        }
        return nil
    }

    private static func animationDurationAndDelay(from mirror: Mirror) -> (
        duration: Double?,
        delay: Double?
    ) {
        var delay: Double?
        var duration: Double?
        for c in mirror.children {
            switch c.label {
            case "delay":
                delay = c.value as? Double
            case "animation":
                duration = animationDuration(from: Mirror(reflecting: c.value))
            default:
                break
            }
        }

        return (duration: duration, delay: delay)
    }

    private static func animationDurationAndRepeat(from mirror: Mirror) -> (
        duration: Double?,
        repeatCount: Int?,
        autoreverses: Bool?
    ) {
        var repeatCount: Int?
        var autoreverses: Bool?
        var duration: Double?
        for c in mirror.children {
            switch c.label {
            case "repeatCount":
                repeatCount = c.value as? Int
            case "autoreverses":
                autoreverses = c.value as? Bool
            case "animation":
                duration = animationDuration(from: Mirror(reflecting: c.value))
            default:
                break
            }
        }
        return (duration: duration, repeatCount: repeatCount, autoreverses: autoreverses)
    }
}
