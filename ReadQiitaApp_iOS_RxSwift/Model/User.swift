//
//  User.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation


struct User :Codable {
    let description: String?
    let facebook_id: String?
    let followees_count: Int
    let followers_count: Int
    let github_login_name: String?
    let id: String
    let items_count: Int
    let linkedin_id: String?
    let location: String?
    let name: String
    let organization: String?
    let permanent_id: Int
    let profile_image_url: String?
    let team_only: Bool
    let twitter_screen_name: String?
    let website_url: String?
}
