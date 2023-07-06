//
//  ArticleViewModel.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/06.
//

import Foundation
import RxSwift
import RxCocoa


struct ArticleViewModel {
    
    private let disposeBag = DisposeBag()
    
    /// 記事がブックマークに追加状態のフラグ
    let isAdded = BehaviorRelay(value: false)
    
    /// 記事がブックマークに追加されているか判定する
    func find(id: String) {
        if Bookmark.find(id: id) == nil {
            isAdded.accept(false)
        } else {
            isAdded.accept(true)
        }
    }
    
    
    func add(id: String, title: String, url: String, success: @escaping () -> Void, failure: @escaping () -> Void)  {
        do {
            let bookmark = Bookmark()
            bookmark.id = id
            bookmark.title = title
            bookmark.url = url
    
            try Bookmark.add(bookmark)
            isAdded.accept(true)
            success()
        } catch {
            failure()
        }
    }
    
    
    func delete(id: String, title: String, url: String, success: @escaping () -> Void, failure: @escaping () -> Void)  {
        do {
            guard let bookmark = Bookmark.find(id: id) else {
                failure()
                return
            }
    
            try Bookmark.delete(bookmark)
            isAdded.accept(false)
            success()
        } catch {
            failure()
        }
    }
    
}
