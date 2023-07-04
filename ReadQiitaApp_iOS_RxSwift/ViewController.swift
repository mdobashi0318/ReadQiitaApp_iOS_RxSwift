//
//  ViewController.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    var viewModel = ArticleListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ReadQiitaApp"
        
        viewModel.getArticles()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        viewModel.articles.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, article, cell in
            cell.textLabel?.text = article.title
        }
        .disposed(by: disposeBag)
        
        
        tableView.rx.modelSelected(Article.self)
            .subscribe(onNext: { [weak self] article in
                let vc: ArticleViewController = ArticleViewController()
                vc.url = article.url
                self?.navigationController?.pushViewController(vc, animated: true)
                
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        })
        .disposed(by: disposeBag)

    }
}

