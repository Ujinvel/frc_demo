//
//  POSIXSyncThreadSafeBox.swift
//  FRCDemo
//   Use with large numbers of write operations.
//   In such cases, much more performant than GCDSyncThreadSafeBox.
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation

final class POSIXSyncThreadSafeBox<Value>: BaseThreadSafeBox<Value>, ThreadSafeBox {
    typealias Value = Value
    
    private var lock = pthread_rwlock_t()
    
    var value: Value {
        get {
            defer { didGet?() }
            
            var tmpValue: Value!
            
            pthread_rwlock_rdlock(&lock)
                tmpValue = self.safeValue
            pthread_rwlock_unlock(&lock)
            
            return tmpValue
        }
        set {
            defer { didSet?(newValue) }
            
            pthread_rwlock_wrlock(&lock)
                safeValue = newValue
            pthread_rwlock_unlock(&lock)
        }
    }
    
    deinit {
        pthread_rwlock_destroy(&lock)
    }
}

extension POSIXSyncThreadSafeBox where Value: OptionalProtocol {
    convenience init(_ optional: Value = Value(reconstructing: nil),
                     didGet: ThreadSafeBox.Get = nil,
                     didSet: ((Value) -> Void)? = nil) {
        self.init(value: optional, didGet: didGet, didSet: didSet)
    }
}
