//
//  ArticleListViewModel.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation
import RxSwift
import RxCocoa


struct  ArticleListViewModel {
    
    let articles = BehaviorRelay<[Article]>(value: [])
    
    
    func getArticles(failure: @escaping () -> Void) {
        APIManager.get(request: "items", success: { response in
            self.articles.accept(response)
        }, failure: { error in
            
            DispatchQueue.main.async {
                print(error.message)
                failure()
            }
            
        })
    
    }
    
    
    
    // 日付のフォーマットを「yyyy年MM月dd日」形式にして返す
    func created_at(_ created_at: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
        let date = dateFormatter.date(from: created_at)
        
        if let date {
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    
    /// 配列のタグの名前を連結して一つの文字列として返す
    func tags(_ tags: [Tags]) -> String {
        var tagNames: [String] = []
        tags.forEach {
            tagNames.append($0.name)
        }
        return tagNames.joined(separator: ",")
    }
    
    
}
