//
//  ArticleViewController.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/04.
//

import UIKit
import WebKit
import RxSwift

class ArticleViewController: UIViewController {
    
    @IBOutlet private weak var webView: WKWebView!
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = ArticleViewModel()
    
    var id: String = ""
    
    var articleTitle: String = ""
    
    var url: String = ""
    
    private let addButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
    
    private let deleteButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.find(id: id)
        initNavigationItem()
        
        guard let url = URL(string: url) else {
            print("url Error")
            // TODO: アラート出す
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    
    private func initNavigationItem() {
        navigationItem.title = "記事"
        
        viewModel.isAdded.asObservable().subscribe(onNext: { [weak self] isAdded in
            guard let self else{
                return
            }
            if isAdded {
                navigationItem.rightBarButtonItem = self.deleteButton
            } else {
                navigationItem.rightBarButtonItem = self.addButton
            }
        })
        .disposed(by: disposeBag)
        
        
        addButton.rx.tap.subscribe(onNext:  { [weak self] in
            guard let self else{
                return
            }
                viewModel.add(id: id, title: articleTitle, url: url, success: {}, failure: {})
        })
        .disposed(by: disposeBag)
        
        
        deleteButton.rx.tap.subscribe(onNext:  { [weak self] in
            guard let self else{
                return
            }
            viewModel.delete(id: id, title: articleTitle, url: url, success: {}, failure: {})
        })
        .disposed(by: disposeBag)
        
    }
}
