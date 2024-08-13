//
//  DisplayLinkDriver+CV.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

import Foundation

#if !canImport(UIKit) && canImport(AppKit)
    import AppKit

    typealias DisplayLinkDriver = CVDisplayLinkDriver

    class CVDisplayLinkDriver: DisplayLinkDriverBase, CVDisplayLinkDriverObject {
        override init() {
            super.init()
            CVDisplayLinkDriverHelper.delegate(self)
        }

        deinit { CVDisplayLinkDriverHelper.remove(self) }

        func synchronize() { synchronizationSubject.send() }
    }

    private protocol CVDisplayLinkDriverObject: AnyObject & Identifiable {
        func synchronize()
    }

    private enum CVDisplayLinkDriverHelper {
        static var displayLink: CVDisplayLink?

        typealias WeakBoxObject = any CVDisplayLinkDriverObject
        struct WeakBox { weak var object: WeakBoxObject? }
        private static var referenceHolder: [WeakBox] = []
        private static let lock = NSLock()

        static func delegate(_ object: WeakBoxObject) {
            lock.lock()
            referenceHolder = referenceHolder
                .filter { $0.object != nil }
                + [.init(object: object)]
            lock.unlock()
            startDisplayLink()
        }

        static func remove(_ object: WeakBoxObject) {
            lock.lock()
            referenceHolder = referenceHolder.filter { $0.object?.id != object.id }
            lock.unlock()
        }

        static func reclaimComputeResourceIfPossible() {
            lock.lock()
            referenceHolder = referenceHolder.filter { $0.object != nil }
            let shouldStop = referenceHolder.isEmpty
            lock.unlock()
            if shouldStop { stopDisplayLink() }
        }

        static func dispatchUpdate() {
            lock.lock()
            for box in referenceHolder {
                box.object?.synchronize()
            }
            lock.unlock()
            reclaimComputeResourceIfPossible()
        }

        static func startDisplayLink() {
            lock.lock()
            defer { lock.unlock() }
            guard displayLink == nil else { return }
            CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
            guard let displayLink else { return }
            CVDisplayLinkSetOutputCallback(displayLink, { _, _, _, _, _, _ -> CVReturn in
                autoreleasepool { CVDisplayLinkDriverHelper.dispatchUpdate() }
                return kCVReturnSuccess
            }, nil)
            CVDisplayLinkStart(displayLink)
        }

        static func stopDisplayLink() {
            lock.lock()
            defer { lock.unlock() }
            if let displayLink { CVDisplayLinkStop(displayLink) }
            displayLink = nil
        }
    }

#endif
