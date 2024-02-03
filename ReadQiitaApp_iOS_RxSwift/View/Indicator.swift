//
//  Indicator.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/02.
//

import UIKit

struct Indicator {
    
    static private let background = UIView()
    
    static private let indicator = UIActivityIndicatorView()

    
    static func show(_ view: UIView?) {
        guard let view else { return }
        
        background.backgroundColor = .black
        background.alpha = 0.7
        view.addSubview(background)
        
        indicator.style = .large
        indicator.color = .white
        background.addSubview(indicator)
        
        background.translatesAutoresizingMaskIntoConstraints = false
        background.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        background.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0.0).isActive = true
        background.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        background.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: background.centerXAnchor, constant: 0.0).isActive = true
        indicator.centerYAnchor.constraint(equalTo: background.centerYAnchor, constant: 0.0).isActive = true
        
        indicator.startAnimating()
    }

    
    static func dismiss() {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
        background.removeFromSuperview()
    }

}
