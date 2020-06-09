//
//  EntityConvertable.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData

protocol EntityConvertable where Self: NSManagedObject {
    associatedtype Entity: ManagedObjectConvertible
    
    func toEntity() -> Entity
}

