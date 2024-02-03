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
    
    private let disposeBag = DisposeBag()
    
    let articles = BehaviorRelay<[Article]>(value: [])
    
    let searchText = BehaviorRelay<String>(value: "")
    
    
    func getArticles(success: @escaping () -> Void, failure: @escaping (String, ErrorResponse.ErrorType) -> Void) {
        APIManager.request(request: "items")
            .subscribe(onNext: { response in
                self.articles.accept(response)
                success()
                
            }, onError: { error  in
                DispatchQueue.main.async {
                    var message = ""
                    if let error = error as? APIError {
                        switch error.type { 
                        case .not_found:
                            message = error.message
                            print("APIError: \(error.message)")
                            failure(message, error.type)
                            
                        default:
                            message = error.message
                            print("APIError: \(error.message)")
                            failure(message, .undefined)
                        }
                        
                    } else {
                        print("APIError: \(error.localizedDescription)")
                        failure(message, .undefined)
                    }
                }
                
            }, onCompleted: {
                print("完了")
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func getTagArticles(success: @escaping () -> Void, failure: @escaping (String, ErrorResponse.ErrorType) -> Void) {
        APIManager.request(request: "tags/\(searchText.value)/items")
            .subscribe(onNext: { response in
                self.articles.accept(response)
                success()
                
            }, onError: { error  in
                DispatchQueue.main.async {
                    var message = ""
                    if let error = error as? APIError {
                        if error.type == .not_found {
                            message = error.message
                        }
                        print("APIError: \(error.message)")
                        failure(message, error.type)
                    } else {
                        print("APIError: \(error.localizedDescription)")
                        failure(message, .undefined)
                        
                    }
                    
                }
                
            }, onCompleted: {
                print("完了")
            })
            .disposed(by: disposeBag)
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
