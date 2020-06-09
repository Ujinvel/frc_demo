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
    
    private lazy var database: Database = .init(persistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    private let backgroundQueue = DispatchQueue(label: String(describing: ViewController.self), qos: .userInitiated)
    private let disposeBag: DisposeBag = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = "random  \(NSUUID().uuidString)"
        let model: TestModel = .init(id: NSUUID().uuidString,
                                     text: text)
        
        backgroundQueue.asyncAfter(deadline: .now() + 3) { [database] in
            database.performWrite { contex, _ in
                let _ = model.toManagedObject(in: contex)
            }
        }

        let byTextRx = CDTestModel.by(text: text).rx
        let allRx = CDTestModel.all().rx
        
        // observe
        byTextRx
            .observe(from: database, on: backgroundQueue)
            .bind {
                print($0)
            }
            .disposed(by: disposeBag)
        
        // fetch
        allRx
            .fetch(from: database, on: backgroundQueue)
            .bind {
                print($0)
            }
            .disposed(by: disposeBag)
    }
}

