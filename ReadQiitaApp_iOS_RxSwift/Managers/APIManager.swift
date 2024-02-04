//
//  APIManager.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation
import Alamofire
import RxSwift


struct APIManager {
    
    private static let baseUrl = "https://qiita.com/api/v2/"
        
    static func request<T: Codable>(request: String, param: Parameters? = nil) -> Observable<T> {
        return Observable.create { observable in
            guard let url = URL(string: baseUrl + request) else {
                observable.onError(APIError(message: "url Error", type: .undefined))
                return Disposables.create()
            }
            
            AF.request(url, parameters: param)
                .validate()
                .responseData { result in
                do {
                    guard let data = result.data else {
                        observable.onError(APIError(message: "response Error", type: .undefined))
                        return
                    }
                    
                    let articles = try JSONDecoder().decode(T.self, from: data)
                    observable.onNext(articles)
                    observable.onCompleted()
                    
                } catch {
                    if let data = result.data, let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        switch errorResponse.type {
                        case ErrorResponse.ErrorType.not_found.rawValue:
                            observable.onError(APIError(message: "検索に一致する記事はありませんでした。", type: .not_found))
                        default:
                            observable.onError(APIError(message: "Decode Error", type: .undefined))
                        }
                        
                    } else {
                        observable.onError(APIError(message: "Unknown Error", type: .undefined))
                    }
                    
                }
                
            }
            return Disposables.create()
        }
    }
    
}


struct APIError: Error {
    var message: String = ""
    var type: ErrorResponse.ErrorType
    
    init(message: String, type: ErrorResponse.ErrorType) {
        self.message = message
        self.type = type
    }
}



struct DBError: Error {
    var message: String = ""
    
    init(message: String) {
        self.message = message
    }
}
