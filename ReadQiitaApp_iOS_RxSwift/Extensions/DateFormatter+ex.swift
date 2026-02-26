//
//  DateFormatter+ex.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2026/02/25.
//

import Foundation

extension DateFormatter {
    
    static var created_at: String {
        format_yyyyMMddHHmmSSSS()
    }

    // 現在日時をの文字列をyyy/MM/dd HH:mm:SSSS形式で返す
    static func format_yyyyMMddHHmmSSSS() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss.sss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter.string(from: Date.now)
    }
    
    
    // Date型をyyy/MM/dd HH:mm形式で文字列を返す
    static func format_yyyyMMddHHmm(_ date: Date = Date.now) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter.string(from: date)
    }
        
    // String型をyyy/MM/dd HH:mm形式でDate型を返す
    static func format_yyyyMMddHHmm_str(_ date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter.date(from: date) ?? Date.now
    }

}
