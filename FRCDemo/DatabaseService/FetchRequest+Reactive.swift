//
//  DatabaseUseCase.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import CoreData
import RxSwift
import RxCocoa

extension Reactive where Base: FetchRequest  {
    func observe(from dataBase: Database,
                 on queue: DispatchQueue? = nil) -> Observable<Updates<Base.RequestResult.Entity>>
    {
        Observable.create { [base] observer in
            let id = NSUUID().uuidString
            let perform: () -> Void = {
                do {
                    try dataBase.addObserver(on: base.fetchRequest, id: id) { dbObserver in
                        dbObserver.didInsert = { entity, newIndexPath, indexPath in
                            observer.onNext(Updates(insert: (entity, newIndexPath),
                                                    delete: nil,
                                                    update: nil,
                                                    move: nil))
                        }
                        dbObserver.didDelete = { entity, newIndexPath, indexPath in
                            observer.onNext(Updates(insert: nil,
                                                    delete: (entity, indexPath),
                                                    update: nil,
                                                    move: nil))
                        }
                        dbObserver.didUpdate = { entity, newIndexPath, indexPath in
                            observer.onNext(Updates(insert: nil,
                                                    delete: nil,
                                                    update: (entity, indexPath),
                                                    move: nil))
                        }
                        dbObserver.didMove = { entity, newIndexPath, indexPath in
                            observer.onNext(Updates(insert: nil,
                                                    delete: nil,
                                                    update: nil,
                                                    move: (entity, newIndexPath, indexPath)))
                        }
                    }
                } catch {
                    observer.onError(error)
                }
            }

            if let queue = queue {
                queue.async {
                    perform()
                }
            } else {
                perform()
            }
            
            return Disposables.create {
                dataBase.removeObserver(on: id)
            }
        }
    }
}

extension Reactive where Base: FetchRequest  {
    func fetch(from dataBase: Database,
               on queue: DispatchQueue? = nil) -> Observable<[Base.RequestResult.Entity]>
    {
        Observable.create { [base] observer in
            let perform: () -> Void = {
                dataBase.perform { context in
                    do {
                        observer.onNext(try context.fetch(base.fetchRequest)
                            .map { $0.toEntity() })
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
            }   
            
            if let queue = queue {
                queue.async {
                    perform()
                }
            } else {
                perform()
            }
            
            return Disposables.create()
        }
    }
}

