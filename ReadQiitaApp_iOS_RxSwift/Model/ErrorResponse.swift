//
//  ErrorResponse.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2024/02/03.
//

import Foundation


struct ErrorResponse: Codable {
    let message: String
    let type: String
    
    enum ErrorType: String {
        case not_found
        case undefined
    }
}
