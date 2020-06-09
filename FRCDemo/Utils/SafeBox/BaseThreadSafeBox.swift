//
//  BaseThreadSafeBox.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation

class BaseThreadSafeBox<Value> {
    var safeValue: Value
    
    let didGet: ThreadSafeBox.Get
    let didSet: ((Value) -> Void)?
    
    required init(value: Value,
                  didGet: ThreadSafeBox.Get = nil,
                  didSet: ((Value) -> Void)? = nil) {
        self.didGet = didGet
        self.didSet = didSet
        self.safeValue = value
    }
}
