import Foundation
import RealmSwift

class History: Object {
    
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var title: String = ""
    @Persisted var url: String = ""
    @Persisted var created_at: String = ""
    @Persisted var updated_at: String = ""
    
    
    private static var realm: Realm? {
        var configuration: Realm.Configuration
        configuration = Realm.Configuration()
        configuration.schemaVersion = UInt64(1)
        return try? Realm(configuration: configuration)
    }
    
    
    static func getAll() -> [History] {
        guard let realm else {
            return []
        }
        
        var model: [History] = []
        realm.objects(History.self).forEach {
            model.append($0)
        }
        
        return model.sorted(by: {
            $0.updated_at > $1.updated_at
        })
    }
    
    
    static func find(id: String) -> History? {
        guard let realm else {
            return nil
        }
        return realm.objects(History.self).filter("id == '\(id)'").first
    }
    
    static func add(_ history: History) throws {
        do {
            guard let realm else {
                throw DBError(message: "初期化エラー")
            }
            
            let date = DateFormatter.created_at
            history.created_at = date
            history.updated_at = date
            
            try realm.write {
                realm.add(history)
            }
        } catch {
#if DEBUG
            print("履歴に追加失敗: \(error)")
#endif
            throw DBError(message: "追加エラー")
        }
    }
    
    static func update(_ history: History, newValue: History) throws {
        do {
            guard let realm else {
                throw DBError(message: "初期化エラー")
            }
            
            try realm.write {
                history.title = newValue.title
                history.url = newValue.url
                history.updated_at = DateFormatter.created_at
                realm.add(history)
            }
        } catch {
#if DEBUG
            print("履歴に更新に失敗: \(error)")
#endif
            throw DBError(message: "更新エラー")
        }
    }
    
    
    static func delete(_ history: History) throws {
        do {
            guard let realm else {
                throw DBError(message: "初期化エラー")
            }
            
            try realm.write {
                realm.delete(history)
            }
        } catch {
            throw DBError(message: "削除エラー")
        }
    }
    
    
    
    
}
