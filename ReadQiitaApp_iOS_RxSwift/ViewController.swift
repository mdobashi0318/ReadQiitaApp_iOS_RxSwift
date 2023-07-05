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
        
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        viewModel.articles.bind(to: tableView.rx.items(cellIdentifier: "ArticleCell", cellType: ArticleCell.self)) { row, article, cell in
            cell.userNameLabel.text = "@\(article.user.id)"
            cell.organizationLabel.text = article.user.organization
            cell.dateLabel.text = self.viewModel.created_at(article.created_at)
            cell.titleLabel.text = article.title
            cell.tagsLabel.text = self.viewModel.tags(article.tags)
            cell.lileCountLabel.text = "\(article.likes_count)"
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

