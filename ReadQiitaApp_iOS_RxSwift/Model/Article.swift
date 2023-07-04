//
//  Article.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation


struct Article: Codable {
    let created_at: String
    let likes_count: Int
    let title: String
    let user: User
    let tags: [Tags]
    let url: String
    let id: String
}
