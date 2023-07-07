//
//  APIManager.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation
import Alamofire



struct APIManager {
    
    private static let baseUrl = "https://qiita.com/api/v2/"
        
    static func get<T: Codable>(request: String, success: @escaping (T) -> Void, failure: @escaping (APIError) -> Void)  {
        guard let url = URL(string: baseUrl + request) else {
            failure(APIError.init(message: "url Error"))
            return
        }
        
        AF.request(url)
            .validate()
            .responseData { result in
            
            do {
                guard let data = result.data else {
                    failure(APIError.init(message: "response Error"))
                    return
                }
                
                let articles = try JSONDecoder().decode(T.self, from: data)
                success(articles)
            } catch {
                failure(APIError.init(message: error.localizedDescription))
            }
            
        }
        
    }
    
}


struct APIError: Error {
    var message: String = ""
    
    init(message: String) {
        self.message = message
    }
}
