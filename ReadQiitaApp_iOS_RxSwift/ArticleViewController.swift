//
//  ArticleViewController.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/04.
//

import UIKit
import WebKit
class ArticleViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    
    var url: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "記事"
        
        guard let url = URL(string: url) else {
            print("url Error")
            // TODO: アラート出す
            return
        }
        webView.load(URLRequest(url: url))
    }
}
