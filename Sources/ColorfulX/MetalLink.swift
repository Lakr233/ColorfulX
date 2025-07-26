//
//  MetalLink.swift
//
//
//  Created by QAQ on 2023/12/4.
//

import Foundation
import MetalKit
import MSDisplayLink

class MetalLink: DisplayLinkDelegate {
    let metalDevice: MTLDevice
    let metalLayer: CAMetalLayer
    let commandQueue: MTLCommandQueue
    let displayLink: DisplayLink = .init()

    typealias SynchornizationUpdate = () -> Void
    var onSynchronizationUpdate: SynchornizationUpdate?

    var scaleFactor: Double = 1.0 {
        didSet { updateDrawableSizeFromFrame() }
    }

    enum MetalError: Error {
        case missingQualifiedHardware
    }

    init() throws {
        guard let metalDevice = MTLCreateSystemDefaultDevice(),
              let commandQueue = metalDevice.makeCommandQueue()
        else {
            throw MetalError.missingQualifiedHardware
        }
        self.metalDevice = metalDevice
        self.commandQueue = commandQueue

        let metalLayer = CAMetalLayer()
        metalLayer.device = metalDevice
        metalLayer.framebufferOnly = false
        metalLayer.isOpaque = false
        metalLayer.presentsWithTransaction = false
        metalLayer.actions = [
            "position": NSNull(),
            "bounds": NSNull(),
            "frame": NSNull(),
            "transform": NSNull(),
            "sublayerTransform": NSNull(),
            "contents": NSNull(),
            "contentsRect": NSNull(),
            "contentsCenter": NSNull()
        ]

        self.metalLayer = metalLayer

        displayLink.delegatingObject(self)
    }

    deinit {
        metalLayer.removeFromSuperlayer()
    }

    func updateDrawableSize(withBounds bounds: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0)

        guard metalLayer.frame != bounds else {
            CATransaction.commit()
            return
        }

        metalLayer.frame = bounds
        updateDrawableSizeFromFrame()
        CATransaction.commit()
    }

    func updateDrawableSizeFromFrame() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(0)

        let bounds = metalLayer.bounds
        var width = bounds.width * scaleFactor
        var height = bounds.height * scaleFactor
        if width <= 1 { width = 1 }
        if height <= 1 { height = 1 }
        if width > 8192 { width = 8192 }
        if height > 8192 { height = 8192 }
        metalLayer.drawableSize = CGSize(width: width, height: height)
        CATransaction.commit()
    }

    func synchronization(context _: DisplayLinkCallbackContext) {
        onSynchronizationUpdate?()
    }
}
