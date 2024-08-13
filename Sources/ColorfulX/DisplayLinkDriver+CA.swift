//
//  DisplayLinkDriver+CA.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

import Foundation

#if canImport(UIKit)
    import UIKit

    typealias DisplayLinkDriver = CADisplayLinkDriver

    class CADisplayLinkDriver: DisplayLinkDriverBase {
        private var displayLink: CADisplayLink?
        private var applicationRunningInForeground: Bool {
            UIApplication.shared.applicationState == .active
        }

        override init() {
            super.init()

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidBecomeActive(_:)),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )

            updateDisplayLink()
        }

        deinit {
            displayLink?.invalidate()
            self.displayLink = nil
            NotificationCenter.default.removeObserver(
                self,
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        }

        func updateDisplayLink() {
            if applicationRunningInForeground {
                guard displayLink == nil else { return }
                let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkCall(_:)))
                displayLink.add(to: .main, forMode: .common)
                self.displayLink = displayLink
            } else {
                guard let displayLink else { return }
                displayLink.invalidate()
                self.displayLink = nil
            }
        }

        @objc
        func applicationDidBecomeActive(_: Notification) {
            updateDisplayLink()
        }

        @objc private func displayLinkCall(_: CADisplayLink) {
            updateDisplayLink()
            synchronizationSubject.send()
        }
    }
#endif
