//
//  MetalView+UIKit.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

#if canImport(UIKit)
    import UIKit

    open class UIMetalView: UIView {
        var metalLink: MetalLink? = try? .init()
        var qualifiedForUpdate: Bool = true

        init() {
            super.init(frame: .zero)
            backgroundColor = .clear

            guard let metalLink else { return }

            isUserInteractionEnabled = false
            
            layer.actions = [
                "position": NSNull(),
                "bounds": NSNull(),
                "frame": NSNull(),
                "transform": NSNull(),
                "sublayerTransform": NSNull()
            ]
            layer.addSublayer(metalLink.metalLayer)
            metalLink.onSynchronizationUpdate = { [weak self] in
                self?.vsyncCheckQualificationAndSend()
            }
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit { metalLink = nil }

        private func updateQualificationCheck() {
            qualifiedForUpdate = [
                window != nil,
                frame.width > 0,
                frame.height > 0,
                alpha > 0,
                !isHidden,
            ].allSatisfy(\.self)
        }

        override open var frame: CGRect {
            get { super.frame }
            set {
                CATransaction.begin()
                CATransaction.setDisableActions(true)

                super.frame = newValue
                CATransaction.commit()
                updateQualificationCheck()
            }
        }

        override open var bounds: CGRect {
            get { super.bounds }
            set {
                CATransaction.begin()
                CATransaction.setDisableActions(true)

                super.bounds = newValue
                CATransaction.commit()
            }
        }
        
        override open var center: CGPoint {
            get { super.center }
            set {
                CATransaction.begin()
                CATransaction.setDisableActions(true)

                super.center = newValue
                CATransaction.commit()
            }
        }

        override open var isHidden: Bool {
            get { super.isHidden }
            set {
                super.isHidden = newValue
                updateQualificationCheck()
            }
        }

        override open var alpha: CGFloat {
            get { super.alpha }
            set {
                super.alpha = newValue
                updateQualificationCheck()
            }
        }

        override open func didMoveToWindow() {
            super.didMoveToWindow()
            updateQualificationCheck()
        }

        override open func didMoveToSuperview() {
            super.didMoveToSuperview()
            updateQualificationCheck()
        }

        private func vsyncCheckQualificationAndSend() {
            guard qualifiedForUpdate else { return }
            vsync()
        }

        func vsync() {}

        override open func layoutSubviews() {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            super.layoutSubviews()
            updateQualificationCheck()
            metalLink?.updateDrawableSize(withBounds: bounds)
            
            CATransaction.commit()
        }
    }
#endif
