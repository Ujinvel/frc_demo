//
//  TestModel+Query.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData

extension CDTestModel {
    static func by(text: String) -> AnyFetchRequest<CDTestModel> {
        with(AnyFetchRequest(NSFetchRequest<CDTestModel>(entityName: String(describing: CDTestModel.self)))) {
            $0.fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDTestModel.id, ascending: true)]
            $0.fetchRequest.predicate = NSPredicate(format: "text = %@", text)
        }
    }
    
    static func all() -> AnyFetchRequest<CDTestModel> {
        with(AnyFetchRequest(NSFetchRequest<CDTestModel>(entityName: String(describing: CDTestModel.self)))) {
            $0.fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CDTestModel.id, ascending: true)]
        }
    }
}
