//
//  Database.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData

final class Database {
    private enum C {
        enum PersistentContainer {
            static let name = "FRCDemo"
        }
    }
    
    struct Update<Request: FetchRequest> {
        typealias Entity = Request.RequestResult.Entity
        
        let entities: [Entity]
        let mapper: (Entity) -> Void
        
        var firstEntity: Entity? {
            entities.first
        }
    }
    
    typealias UpdateBlock
        <Request: FetchRequest> = (
        update: Update<Request>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock2
        <Request1: FetchRequest, Request2: FetchRequest> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock3
        <Request1: FetchRequest, Request2: FetchRequest, Request3: FetchRequest> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        update3: Update<Request3>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    typealias UpdateBlock4
        <Request1: FetchRequest, Request2: FetchRequest, Request3: FetchRequest, Request4: FetchRequest> = (
        update1: Update<Request1>,
        update2: Update<Request2>,
        update3: Update<Request3>,
        update4: Update<Request4>,
        context: NSManagedObjectContext,
        mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void,
        error: Error?
    )
    
    // MARK: - Properties
    // shared
    static let shared = Database()
    // concurrent queue for execution performAndWait on reading
    let performQueue = DispatchQueue(label: "Database performQueue", qos: .userInitiated, attributes: .concurrent)
    // core data
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
    private lazy var persistentContainer: NSPersistentContainer = NSPersistentContainer(name: C.PersistentContainer.name)
    // frc observers
    private let observers: AnyThreadSafeBox<[String: Any]> = .init(POSIXSyncThreadSafeBox(value: [:]))
    // perform write sync queue
    private let syncQueue = DispatchQueue(label: "Database syncQueue", qos: .userInitiated)
    
    // MARK: - Initialization
    
    private init() { }
    
    // MARK: - Functions
    
    func load(_ completion: @escaping (Error?) -> Void) {
        persistentContainer.loadPersistentStores { _, error in
            completion(error)
        }
    }
    
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
        performQueue.async { [weak self] in
            self?.backgroundContext.performAndWait {
                self.map { `self` in
                    self.observers.value = self.observers.value.filter { $0.key != id }
                }
            }
        }
    }
    
    // MARK: Perform
    
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        performQueue.async { [unowned self] in
            self.backgroundContext.performAndWait {
                block(self.backgroundContext)
            }
        }
    }
    
    func update<Request: FetchRequest>(
        _ request: Request,
        block: @escaping (UpdateBlock<Request>) -> Void)
    {
        let mapper: (UpdateBlock4<Request, Request, Request, Request>) -> Void = {
            block((update: $0.update1,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   error: $0.error))
        }
        
        update(request, .none, .none, .none, block: mapper)
    }
    
    func update<Request1: FetchRequest, Request2: FetchRequest>(
        _ request1: Request1,
        _ request2: Request2,
        block: @escaping (UpdateBlock2<Request1, Request2>) -> Void)
    {
        let mapper: (UpdateBlock4<Request1, Request2, Request1, Request1>) -> Void = {
            block((update1: $0.update1,
                   update2: $0.update2,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   error: $0.error))
        }
        
        update(request1, request2, .none, .none, block: mapper)
    }
    
    func update<Request1: FetchRequest, Request2: FetchRequest, Request3: FetchRequest>(
        _ request1: Request1,
        _ request2: Request2,
        _ request3: Request3,
        block: @escaping (UpdateBlock3<Request1, Request2, Request3>) -> Void)
    {
        let mapper: (UpdateBlock4<Request1, Request2, Request3, Request1>) -> Void = {
            block((update1: $0.update1,
                   update2: $0.update2,
                   update3: $0.update3,
                   context: $0.context,
                   mainQueueWrapper: $0.mainQueueWrapper,
                   error: $0.error))
        }
        
        update(request1, request2, request3, .none, block: mapper)
    }
    
    func update<Request1: FetchRequest, Request2: FetchRequest, Request3: FetchRequest, Request4: FetchRequest>(
        _ request1: Request1,
        _ request2: Request2?,
        _ request3: Request3?,
        _ request4: Request4?,
        block: @escaping (UpdateBlock4<Request1, Request2, Request3, Request4>) -> Void)
    {
        // syncQueue is a serial queue that ensures that only one block will be executed at a time
        syncQueue.async { [weak self] in
            self?.performWrite { context in
                let toManagedObjectMapper1: (Request1.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper2: (Request2.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper3: (Request3.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }
                let toManagedObjectMapper4: (Request4.RequestResult.Entity) -> Void = {
                    _ = $0.toManagedObject(in: context)
                }

                let mainQueueWrapper: (@autoclosure @escaping () -> Void) -> Void = { block in
                    DispatchQueue.main.async(execute: .init(block: block))
                }

                var entities1: [Request1.RequestResult.Entity] = []
                var entities2: [Request2.RequestResult.Entity] = []
                var entities3: [Request3.RequestResult.Entity] = []
                var entities4: [Request4.RequestResult.Entity] = []

                do {
                    entities1 = try context.fetch(request1.fetchRequest).map { $0.toEntity() }
                    
                    if let request2 = request2 {
                        entities2 = try context.fetch(request2.fetchRequest).map { $0.toEntity() }
                    }
                    if let request3 = request3 {
                        entities3 = try context.fetch(request3.fetchRequest).map { $0.toEntity() }
                    }
                    if let request4 = request4 {
                        entities4 = try context.fetch(request4.fetchRequest).map { $0.toEntity() }
                    }

                    block((update1: .init(entities: entities1, mapper: toManagedObjectMapper1),
                           update2: .init(entities: entities2, mapper: toManagedObjectMapper2),
                           update3: .init(entities: entities3, mapper: toManagedObjectMapper3),
                           update4: .init(entities: entities4, mapper: toManagedObjectMapper4),
                           context: context,
                           mainQueueWrapper: mainQueueWrapper,
                           error: nil))
                } catch {
                    block((update1: .init(entities: entities1, mapper: toManagedObjectMapper1),
                           update2: .init(entities: entities2, mapper: toManagedObjectMapper2),
                           update3: .init(entities: entities3, mapper: toManagedObjectMapper3),
                           update4: .init(entities: entities4, mapper: toManagedObjectMapper4),
                           context: context,
                           mainQueueWrapper: mainQueueWrapper,
                           error: error))
                }
            }
        }
    }
    
    private func performWrite(block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.performAndWait { [backgroundContext] in
            block(backgroundContext)
            
            if backgroundContext.hasChanges {
                do {
                    try backgroundContext.save()
                } catch {
                    print(error)
                    //Crashlytics.sharedInstance().recordError(error)
                }
            }
        }
    }
}
