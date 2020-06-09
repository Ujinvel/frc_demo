//
//  FetchResultsObserverUseCase.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import Foundation

protocol FetchResultsObserverUseCase: class {
    associatedtype Entity
    
    typealias Update = (Entity, IndexPath) -> Void
    
    var didInsert: ((Entity, IndexPath?, IndexPath?) -> Void)? { get set }
    var didDelete: ((Entity, IndexPath?, IndexPath?) -> Void)? { get set }
    var didMove: ((Entity, IndexPath?, IndexPath?) -> Void)? { get set }
    var didUpdate: ((Entity, IndexPath?, IndexPath?) -> Void)? { get set }
}

struct Updates<Entity> {
    let insert: (Entity, IndexPath?)?
    let delete: (Entity, IndexPath?)?
    let update: (Entity, IndexPath?)?
    let move: (Entity, IndexPath?, IndexPath?)?
}

final class AnyFetchResultsObserver<Entity>: FetchResultsObserverUseCase {
    
    // MARK: - FetchResultsObserverUseCase
    
    var didInsert: ((Entity, IndexPath?, IndexPath?) -> Void)? {
        get { getDidInsert() }
        set { setDidInsert(newValue) }
    }
    var didDelete: ((Entity, IndexPath?, IndexPath?) -> Void)? {
        get { getDelete() }
        set { setDelete(newValue) }
    }
    var didMove: ((Entity, IndexPath?, IndexPath?) -> Void)? {
        get { getMove() }
        set { setMove(newValue) }
    }
    var didUpdate: ((Entity, IndexPath?, IndexPath?) -> Void)? {
        get { getUpdate() }
        set { setUpdate(newValue) }
    }
    
    // MARK: - Properties
    
    private let getDidInsert: () -> ((Entity, IndexPath?, IndexPath?) -> Void)?
    private let setDidInsert: (((Entity, IndexPath?, IndexPath?) -> Void)?) -> Void
    private let getDelete: () -> ((Entity, IndexPath?, IndexPath?) -> Void)?
    private let setDelete: (((Entity, IndexPath?, IndexPath?) -> Void)?) -> Void
    private let getMove: () -> ((Entity, IndexPath?, IndexPath?) -> Void)?
    private let setMove: (((Entity, IndexPath?, IndexPath?) -> Void)?) -> Void
    private let getUpdate: () -> ((Entity, IndexPath?, IndexPath?) -> Void)?
    private let setUpdate: (((Entity, IndexPath?, IndexPath?) -> Void)?) -> Void

    // MARK: - Initialization
    
    init<T: FetchResultsObserverUseCase>(_ observer: T) where T.Entity == Entity {
        getDidInsert = { observer.didInsert }
        setDidInsert = { observer.didInsert = $0 }
        getDelete = { observer.didDelete }
        setDelete = { observer.didDelete = $0 }
        getMove = { observer.didMove }
        setMove = { observer.didMove = $0 }
        getUpdate = { observer.didUpdate }
        setUpdate = { observer.didUpdate = $0 }
    }
}


