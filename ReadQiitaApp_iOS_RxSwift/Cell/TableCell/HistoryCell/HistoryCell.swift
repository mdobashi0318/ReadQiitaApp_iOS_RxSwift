//
//  HistoryCell.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2026/02/28.
//

import UIKit

final class HistoryCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setView(history: History) {
        titleLabel.text = history.title
        let date = DateFormatter.format_yyyyMMddHHmmsssss_str(history.updated_at)
        let str = DateFormatter.format_yyyyMMddHHmm(date)
        dateLabel.text = str
    }
    
}
