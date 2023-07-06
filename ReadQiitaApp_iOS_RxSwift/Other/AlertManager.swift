//
//  AlertManager.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/06.
//

import UIKit

struct AlertManager {
    
    enum AlertType: CaseIterable {
        case retry, ok
    }
    
    /// アラートを表示する
    /// - Parameters:
    ///   - vc: ViewController
    ///   - type: 出すアラートのタイプを設定する
    static func showAlert(_ vc: UIViewController, type: AlertType, title: String? = nil, message: String, didTapPositiveButton: ((UIAlertAction) -> Void)? = nil, didTapNegativeButton: ((UIAlertAction) -> Void)? = nil) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        switch type {
        case .retry:
            controller.addAction(UIAlertAction(title: "再接続",
                                               style: .default,
                                               handler: didTapPositiveButton)
            )
            
            controller.addAction(UIAlertAction(title: "閉じる",
                                               style: .cancel,
                                               handler: didTapNegativeButton)
            )
        case .ok:
            controller.addAction(UIAlertAction(title: "OK",
                                               style: .cancel,
                                               handler: didTapPositiveButton))
        }
        
        vc.present(controller, animated: true, completion: nil)
    }
    
}
