//
//  Safe.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation
import RxCocoa

protocol ThreadSafeBox: class {
    associatedtype Value
    
    typealias Get = (() -> Void)?
    typealias Set = ((Value) -> Void)?
    
    var value: Value { get set }
}

final class AnyThreadSafeBox<Value>: ThreadSafeBox {
    private let setValue: (Value) -> Void
    private let getValue: () -> Value
    
    var value: Value {
        get {
            getValue()
        }
        set {
            setValue(newValue)
        }
    }
    
    init<T: ThreadSafeBox>(_ box: T) where T.Value == Value {
        getValue = { box.value }
        setValue = { box.value = $0 }
    }
}
