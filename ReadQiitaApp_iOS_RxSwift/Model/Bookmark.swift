//
//  Bookmark.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/06.
//

import Foundation
import RealmSwift

class Bookmark: Object {
    
    @Persisted(primaryKey: true) var id: String = ""
    
    @Persisted var title: String = ""
    
    @Persisted var url: String = ""
    
    
    private static var realm: Realm? {
        var configuration: Realm.Configuration
        configuration = Realm.Configuration()
        configuration.schemaVersion = UInt64(1)
        return try? Realm(configuration: configuration)
    }
    
    
    static func getAll() -> [Bookmark] {
        guard let realm else {
            return []
        }
        
        var model: [Bookmark] = []
        realm.objects(Bookmark.self).forEach {
            model.append($0)
        }
        
        return model
        
    }
    
    
    static func find(id: String) -> Bookmark? {
        guard let realm else {
            return nil
        }
            
        return realm.objects(Bookmark.self).filter("id == '\(id)'").first
    }
    
    static func add(_ bookmark: Bookmark) throws {
        do {
            guard let realm else {
                throw APIError(message: "初期化エラー")
            }
            
            try realm.write {
                realm.add(bookmark)
            }
        } catch {
            throw APIError(message: "追加エラー")
        }
    }
    
    
    static func delete(_ bookmark: Bookmark) throws {
        do {
            guard let realm else {
                throw APIError(message: "初期化エラー")
            }
            
            try realm.write {
                realm.delete(bookmark)
            }
        } catch {
            throw APIError(message: "削除エラー")
        }
    }
    
    
    
    
}
