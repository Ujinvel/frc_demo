//
//  Database.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData

final class Database {
    // MARK: - Properties
    
    private lazy var viewContext: NSManagedObjectContext = {
        with(persistentContainer.viewContext) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    private lazy var backgroundContext: NSManagedObjectContext = {
        with(persistentContainer.newBackgroundContext()) {
            $0.automaticallyMergesChangesFromParent = true
            $0.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        }
    }()
    
    private let persistentContainer: NSPersistentContainer
    private var observers: AnyThreadSafeBox<[String: Any]> = .init(POSIXSyncThreadSafeBox(value: [:]))
    
    // MARK: - Initialization
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    deinit {
        observers.value = [:]
    }
    
    // MARK: - Functions
    // MARK: Add/remove observers
    
    func addObserver<T: EntityConvertable>(on fetchRequest: NSFetchRequest<T>,
                                           id: String,
                                           _ builder: ((AnyFetchResultsObserver<T.Entity>) -> Void)? = nil) throws
    {
        var err: Error?
        backgroundContext.performAndWait { [weak self] in
            self.map { `self` in
                let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                     managedObjectContext: self.backgroundContext,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: id)
                var observers = self.observers.value.filter { $0.key != id }
                let observer = AnyFetchResultsObserver(FetchResultsObserver(fetchResultcontroller: frc))
                observers[id] = observer
                self.observers.value = observers
            
                do {
                    try frc.performFetch()
                } catch {
                    err = error
                }
            
                builder?(observer)
            }
        }
        
        if let error = err {
            throw error
        }
    }
    
    func removeObserver(on id: String) {
        backgroundContext.performAndWait { [weak self] in
            self.map { `self` in
                observers.value = observers.value.filter { $0.key != id }
            }
        }
    }
    
    // MARK: Perform
    
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.performAndWait { [backgroundContext] in
            block(backgroundContext)
        }
    }
    
    func performWrite(_ block: @escaping (NSManagedObjectContext, Error?) -> Void) {
        performWrite(block: block, completion: nil)
    }
    
    func performWrite(
        block: @escaping (NSManagedObjectContext, Error?) -> Void,
        completion: (() -> Void)?)
    {
        backgroundContext.performAndWait { [backgroundContext] in
            block(backgroundContext, nil)
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                } catch {
                    block(backgroundContext, error)
                }
            }
            
            completion?()
        }
    }
}
