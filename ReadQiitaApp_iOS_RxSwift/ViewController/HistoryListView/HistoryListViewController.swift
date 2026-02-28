//
//  HistoryListViewController.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2026/02/23.
//

import UIKit
import RxSwift
import RxCocoa

class HistoryListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLable: UILabel!
    private let disposeBag = DisposeBag()
    private let historyList = BehaviorRelay<[History]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        initTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        historyList.accept(History.getAll())
        
        if historyList.value.isEmpty {
            noDataLable.isHidden = false
        } else {
            noDataLable.isHidden = true
        }
    }
    
    
    private func initNavigationItem() {
        navigationItem.title = "閲覧履歴"
        
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
        historyList.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, history, cell in
            cell.textLabel?.text = history.title
            
        }
        .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
}


extension HistoryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc: ArticleViewController = ArticleViewController()
        let article = historyList.value[indexPath.row]
        vc.id = article.id
        vc.articleTitle = article.title
        vc.url = article.url
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .destructive, title: "削除", handler: { _, _, completionHandler in
            try? History.delete(self.historyList.value[indexPath.row])
            self.historyList.accept(History.getAll())
            completionHandler(true)
        })
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
