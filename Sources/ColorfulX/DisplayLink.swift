//
//  DisplayLink.swift
//
//
//  Created by 秋星桥 on 2024/8/13.
//

import Combine
import Foundation

protocol DisplayLinkDelegate: AnyObject {
    func synchronization()
}

class DisplayLink {
    private weak var delegatingObject: DisplayLinkDelegate?

    private var driver: DisplayLinkDriver?
    private var driverSubscription: Set<AnyCancellable> = .init()

    init() {
        let driver = DisplayLinkDriver()
        driver.synchronizationPublisher
            .sink { [weak self] _ in self?.delegatingObject?.synchronization() }
            .store(in: &driverSubscription)
        self.driver = driver
    }

    deinit { teardown() }

    func teardown() {
        driverSubscription.forEach { $0.cancel() }
        driverSubscription.removeAll()
        driver = nil
    }

    func delegatingObject(_ object: DisplayLinkDelegate) {
        delegatingObject = object
    }
}
