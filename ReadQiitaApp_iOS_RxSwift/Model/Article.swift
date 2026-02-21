//
//  Article.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation


struct Article: Codable, Hashable {
    let created_at: String
    let likes_count: Int
    let title: String
    let user: User
    let tags: [Tags]
    let url: String
    let id: String
}



extension Article {
    
    // 日付のフォーマットを「yyyy年MM月dd日」形式にして返す
    func formatCreatedAt() -> String {
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
    
    func joinedTagNames() -> String {
        var tagNames: [String] = []
        tags.forEach {
            tagNames.append($0.name)
        }
        return tagNames.joined(separator: ",")
    }
    
    
}
