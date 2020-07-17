//
//  ViewController.swift
//  FRCDemo
//
//  Created by Evgeny Velichko on 09.06.2020.
//  Copyright © 2020 Evgeny Velichko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {
    
    private lazy var database: Database = Database.shared
    private let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
            
        database.load { [database, disposeBag] error in
            let text = "random  \(NSUUID().uuidString)"
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [database] in
                database.update(CDTestModel.all()) { cd in
                    
                    let model: TestModel = .init(id: NSUUID().uuidString,
                                                 text: text)
                    cd.update.mapper(model)
                    cd.mainQueueWrapper(print("Exit from update block, perform on main thread"))
                }
            }

            let byTextRx = CDTestModel.by(text: text).rx
            let allRx = CDTestModel.all().rx
            
            // observe
            byTextRx
                .observe(from: database)
                .bind {
                    print($0)
                }
                .disposed(by: disposeBag)
            
            // fetch
            allRx
                .fetch(from: database)
                .bind {
                    print($0)
                }
                .disposed(by: disposeBag)
        }
    }
}

