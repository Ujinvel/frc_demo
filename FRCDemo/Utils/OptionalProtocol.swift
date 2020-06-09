//
//  OptionalProtocol.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

/// An optional protocol for use in type constraints.
public protocol OptionalProtocol {
    /// The type contained in the otpional.
    associatedtype Wrapped
    
    init(reconstructing value: Wrapped?)
    
    /// Extracts an optional from the receiver.
    var optional: Wrapped? { get }
}

extension Optional: OptionalProtocol {
    public var optional: Wrapped? {
        self
    }
    
    public init(reconstructing value: Wrapped?) {
        self = value
    }
}
