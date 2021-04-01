//
//  Syncronized.swift
//  Portal
//
//  Created by Farid on 13.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

public class Synchronized<T> {
    /// Private value. Use `public` `value` computed property (or `reader` and `writer` methods)
    /// for safe, thread-safe access to this underlying value.
    
    private var _value: T
    
    /// Private reader-write synchronization queue
    
    private let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".synchronized", qos: .default, attributes: .concurrent)
    
    /// Create `Synchronized` object
    ///
    /// - Parameter value: The initial value to be synchronized.
    
    public init(_ value: T) {
        _value = value
    }
    
    /// A threadsafe variable to set and get the underlying object
    
    public var value: T {
        get { queue.sync { _value } }
        set { queue.async(flags: .barrier) { self._value = newValue } }
    }
    
    /// A "reader" method to allow thread-safe, read-only concurrent access to the underlying object.
    ///
    /// - Warning: If the underlying object is a reference type, you are responsible for making sure you
    ///            do not mutating anything. If you stick with value types (`struct` or primitive types),
    ///            this will be enforced for you.
    
    public func reader<U>(_ block: (T) throws -> U) rethrows -> U {
        try queue.sync { try block(_value) }
    }
    
    /// A "writer" method to allow thread-safe write with barrier to the underlying object
    
    func writer(_ block: @escaping (inout T) -> Void) {
        queue.async(flags: .barrier) {
            block(&self._value)
        }
    }
}
