//
//  MetalView+AppKit.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

import Foundation

#if !canImport(UIKit) && canImport(AppKit)

    import AppKit

    open class NSMetalView: NSView, CALayerDelegate {
        var metalLink: MetalLink? = try? .init()
        var qualifiedForUpdate: Bool = true

        init() {
            super.init(frame: .zero)

            wantsLayer = true
            if let metalLink, let layer {
                layer.addSublayer(metalLink.metalLayer)
                metalLink.metalLayer.delegate = self
                metalLink.onSynchronizationUpdate = { [weak self] in
                    self?.vsyncCheckQualificationAndSend()
                }
            }
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit { metalLink = nil }

        func vsync() {}

        private func updateQualificationCheck() {
            qualifiedForUpdate = [
                window != nil,
                frame.width > 0,
                frame.height > 0,
                alphaValue > 0,
                !isHidden,
            ].allSatisfy { $0 }
        }

        override open var frame: NSRect {
            get { super.frame }
            set {
                super.frame = newValue
                updateQualificationCheck()
            }
        }

        override open var isHidden: Bool {
            get { super.isHidden }
            set {
                super.isHidden = newValue
                updateQualificationCheck()
            }
        }

        override open var alphaValue: CGFloat {
            get { super.alphaValue }
            set {
                super.alphaValue = newValue
                updateQualificationCheck()
            }
        }

        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            updateQualificationCheck()
        }

        private func vsyncCheckQualificationAndSend() {
            guard qualifiedForUpdate else { return }
            vsync()
        }

        override open func layout() {
            super.layout()
            updateQualificationCheck()
            guard let metalLayer = metalLink?.metalLayer else { return }
            layoutSublayers(of: metalLayer)
        }

        public func layoutSublayers(of _: CALayer) {
            metalLink?.updateDrawableSize(withBounds: bounds)
        }
    }
#endif
