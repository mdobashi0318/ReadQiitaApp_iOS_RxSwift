//
//  APIManager.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import Foundation
import RxSwift
import RxCocoa



struct APIManager {
    
    private static let baseUrl = "https://qiita.com/api/v2/"
    
    private static let disposeBag = DisposeBag()
    
    static func get<T: Codable>(request: String, success: @escaping (T) -> Void, failure: @escaping (APIError) -> Void)  {
        
        let session = URLSession.shared
        
        guard let url = URL(string: baseUrl + request) else {
            failure(APIError.init(message: "url Error"))
            return
        }
        
        session.rx.response(request: URLRequest(url: url))
            .subscribe { response, data in
                do {
                    guard 200 ..< 300 ~= response.statusCode else {
                        throw APIError.init(message: "statusCode: \(response.statusCode)")
                    }
                    let articles = try JSONDecoder().decode(T.self, from: data)
                    success(articles)
                } catch {
                    failure(APIError.init(message: error.localizedDescription))
                }
            }.disposed(by: disposeBag)
        
    }

}


struct APIError: Error {
    var message: String = ""
    
    init(message: String) {
        self.message = message
    }
}
