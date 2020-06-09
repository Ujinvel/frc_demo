//
//  ManagedObjectConvertable.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData

protocol ManagedObjectConvertible {
    associatedtype ManagedObject: EntityConvertable
    
    func toManagedObject(in context: NSManagedObjectContext) -> ManagedObject
}

extension NSManagedObject  {
    fileprivate class var entityName: String {
        NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
    
    static func firstOrCreate(context: NSManagedObjectContext,
                              id: String) -> Self
    {
        let request = with(NSFetchRequest<Self>(entityName: entityName)) {
            $0.predicate = NSPredicate(format: "id = %@", id)
        }
        
        if let object = try? context.fetch(request).first {
            return object
        } else if let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            return .init(entity: entity, insertInto: context) as Self
        } else {
            fatalError("Can't create object \(Self.self) with id: \(id)")
        }
    }
}

