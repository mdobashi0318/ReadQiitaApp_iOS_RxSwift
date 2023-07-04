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
    
    
    func getArticles() {
        APIManager.get(request: "items", success: { response in
            self.articles.accept(response)
        }, failure: { error in
            print(error.message)
            // TODO: アラート表示
        })
    
    }
    
    
}
