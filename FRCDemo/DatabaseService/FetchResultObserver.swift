//
//  FetchRequestObserver.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData

final class FetchResultsObserver<FetchResults: EntityConvertable>: NSObject,
    NSFetchedResultsControllerDelegate,
    FetchResultsObserverUseCase {
    
    // MARK: - Properties
    // MARK: FetchResultsObserverUseCase
    
    var didInsert: ((FetchResults.Entity, IndexPath?, IndexPath?) -> Void)?
    var didDelete: ((FetchResults.Entity, IndexPath?, IndexPath?) -> Void)?
    var didMove: ((FetchResults.Entity, IndexPath?, IndexPath?) -> Void)?
    var didUpdate: ((FetchResults.Entity, IndexPath?, IndexPath?) -> Void)?
    
    fileprivate let fetchResultcontroller: NSFetchedResultsController<FetchResults>
    
    // MARK: - Initialization
    
    init<Entity>(fetchResultcontroller: NSFetchedResultsController<FetchResults>,
                 didInsert: ((Entity, IndexPath?, IndexPath?) -> Void)? = nil,
                 didDelete: ((Entity, IndexPath?, IndexPath?) -> Void)? = nil,
                 didMove: ((Entity, IndexPath?, IndexPath?) -> Void)? = nil,
                 didUpdate: ((Entity, IndexPath?, IndexPath?) -> Void)? = nil) where FetchResults.Entity == Entity {
        self.didInsert = didInsert
        self.didDelete = didDelete
        self.didMove = didMove
        self.didUpdate = didUpdate
        self.fetchResultcontroller = fetchResultcontroller
        
        super.init()
        
        fetchResultcontroller.delegate = self
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print(Thread.current)
//        print("WillChangeContent")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        print(Thread.current)
//        print("DidChangeContent")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
    {
        let mapper: (((FetchResults.Entity, IndexPath?, IndexPath?) -> Void)?) -> Void = { callback in
            (anObject as? FetchResults)
                .map { object in
                    callback?(object.toEntity(), newIndexPath, indexPath)
                }
        }
        switch type {
        case .insert:
            mapper(didInsert)
        case .delete:
            mapper(didDelete)
        case .move:
            mapper(didMove)
        case .update:
            mapper(didUpdate)
        }
    }
}

