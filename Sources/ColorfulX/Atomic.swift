//
//  Atomic.swift
//  ColorfulX
//
//  Created by QAQ on 2024/2/6.
//

import Foundation

@propertyWrapper
public struct Atomic<Value> {
    private var value: Value
    private let lock = NSLock()

    public init(wrappedValue value: Value) {
        self.value = value
    }

    public var wrappedValue: Value {
        get { load() }
        set { store(newValue: newValue) }
    }

    func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}
