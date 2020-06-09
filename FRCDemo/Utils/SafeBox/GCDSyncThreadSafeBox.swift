//
//  GCDSyncThreadSafeBox.swift
//  FRCDemo
//
//  Do not use for large numbers of write operations from different streams (for example, in an array)!!!!
//  In such cases, the cost of switching queues greatly slows down the work
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation

final class GCDSyncThreadSafeBox<Value>: BaseThreadSafeBox<Value>, ThreadSafeBox {
    typealias Value = Value
    
    private let syncQueue = DispatchQueue(label: "", qos: .userInitiated, attributes: .concurrent)
    
    var value: Value {
        get {
            defer { didGet?() }
            
            var tmpValue: Value!
            
            syncQueue.sync { [unowned self] in
                tmpValue = self.safeValue
            }
            
            return tmpValue
        }
        set {
            defer { didSet?(newValue) }
            
            syncQueue.async(flags: .barrier) { [weak self] in
                self?.safeValue = newValue
            }
        }
    }
}

extension GCDSyncThreadSafeBox where Value: OptionalProtocol {
    convenience init(_ optional: Value = Value(reconstructing: nil),
                     didGet: ThreadSafeBox.Get = nil,
                     didSet: ((Value) -> Void)? = nil) {
        self.init(value: optional, didGet: didGet, didSet: didSet)
    }
}
