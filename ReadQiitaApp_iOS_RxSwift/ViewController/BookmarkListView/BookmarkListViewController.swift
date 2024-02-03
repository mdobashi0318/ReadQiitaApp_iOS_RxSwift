//
//  BookmarkListViewController.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa

class BookmarkListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet weak var noDataLable: UILabel!

    private let disposeBag = DisposeBag()
    
    private let bookmarkList = BehaviorRelay<[Bookmark]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        initTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bookmarkList.accept(Bookmark.getAll())
        
        if bookmarkList.value.isEmpty {
            noDataLable.isHidden = false
        } else {
            noDataLable.isHidden = true
        }
    }
    
    
    private func initNavigationItem() {
        navigationItem.title = "ブックマーク"
        
        let closeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = closeButton
        
        closeButton.rx.tap.subscribe(onNext:  { [weak self] in
            self?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
    }
    
    
    private func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // セルをセット
        bookmarkList.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, bookmark, cell in
            cell.textLabel?.text = bookmark.title
            
        }
        .disposed(by: disposeBag)
        
        // セルタップ
        tableView.rx.modelSelected(Bookmark.self)
            .subscribe(onNext: { [weak self] article in
                let vc: ArticleViewController = ArticleViewController()
                vc.id = article.id
                vc.articleTitle = article.title
                vc.url = article.url
                self?.navigationController?.pushViewController(vc, animated: true)
                
            })
            .disposed(by: disposeBag)
        
        // 選択状態のハイライト解除
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        })
        .disposed(by: disposeBag)
    }
    
}
