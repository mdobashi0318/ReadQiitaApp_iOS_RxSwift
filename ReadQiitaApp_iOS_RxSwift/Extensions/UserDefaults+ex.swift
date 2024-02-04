//
//  UserDefaults+ex.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/04.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case searchMode
    }
    
    
    func set<T>(value: T, key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    
    func get<T>(key: Key) -> T? {
        guard let value = UserDefaults.standard.object(forKey: key.rawValue) as? T else {
            return nil
        }
        return value
    }
}
