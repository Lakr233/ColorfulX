//
//  MetalView+UIKit.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

#if canImport(UIKit)
    import UIKit

    open class MetalView: UIView {
        var metalLink: MetalLink? = try? .init()
        var qualifiedForUpdate: Bool = true

        init() {
            super.init(frame: .zero)
            backgroundColor = .clear

            guard let metalLink else { return }

            isUserInteractionEnabled = false
            layer.addSublayer(metalLink.metalLayer)
            assert(metalLink.metalLayer.delegate == nil)
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
                scene?.activationState == .foregroundActive,
                frame.width > 0,
                frame.height > 0,
                alpha > 0,
                !isHidden,
            ].allSatisfy { $0 }
        }

        override open var frame: CGRect {
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
            super.layoutSubviews()
            metalLink?.updateDrawableSize(withBounds: bounds)
        }
    }

    extension UIResponder {
        @objc var scene: UIScene? { nil }
    }

    extension UIScene {
        @objc override var scene: UIScene? { self }
    }

    extension UIView {
        @objc override var scene: UIScene? {
            if let window {
                window.windowScene
            } else {
                next?.scene
            }
        }
    }

    extension UIViewController {
        @objc override var scene: UIScene? {
            var res = next?.scene
            if res == nil { res = parent?.scene }
            if res == nil { res = presentingViewController?.scene }
            return res
        }
    }
#endif