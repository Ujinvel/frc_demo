//
//  TestModel.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation
import CoreData

struct TestModel {
    let id: String
    let text: String
}


// MARK: - EntityConvertable

extension CDTestModel: EntityConvertable {
    func toEntity() -> TestModel {
        .init(id: id ?? "",
              text: text ?? "")
    }
}

// MARK: - ManagedObjectConvertible

extension TestModel: ManagedObjectConvertible {
    func toManagedObject(in context: NSManagedObjectContext) -> CDTestModel {
        with(CDTestModel.firstOrCreate(context: context, id: id)) {
            $0.id = id
            $0.text = text
        }
    }
}
