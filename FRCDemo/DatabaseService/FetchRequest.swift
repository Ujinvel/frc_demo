//
//  FetchRequest.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation
import CoreData

protocol FetchRequest where Self: NSObject {
    associatedtype RequestResult: EntityConvertable
    
    var fetchRequest: NSFetchRequest<RequestResult> { get }
}

final class AnyFetchRequest<T: EntityConvertable>: NSObject, FetchRequest {
    typealias RequestResult = T
    
    let fetchRequest: NSFetchRequest<T>
    
    init(_ fetchRequest: NSFetchRequest<T>) {
        self.fetchRequest = fetchRequest
        
        super.init()
    }
}
