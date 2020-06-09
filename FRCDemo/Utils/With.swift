//
//  With.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation

public func with<T>(_ value: T,
                    _ builder: (T) -> Void) -> T
{
    builder(value)
    return value
}
