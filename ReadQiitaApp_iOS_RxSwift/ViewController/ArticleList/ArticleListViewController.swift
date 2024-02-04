//
//  ViewController.swift
//  ReadQiitaApp_iOS_RxSwift
//
//  Created by 土橋正晴 on 2023/07/03.
//

import UIKit
import RxSwift
import RxCocoa

class ArticleListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    @IBOutlet weak var noDataLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = ArticleListViewModel()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initNavigationItem()
        initTableView()
        initSearchbar()
    }
    
}



// MARK: - SetUI

extension ArticleListViewController {
    
    private func initTableView() {
        getArticleList()
        
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        tableView.refreshControl = refreshControl
        
        // セルをセット
        viewModel.articles.bind(to: tableView.rx.items(cellIdentifier: "ArticleCell", cellType: ArticleCell.self)) { row, article, cell in
            cell.userNameLabel.text = "@\(article.user.id)"
            cell.organizationLabel.text = article.user.organization
            cell.dateLabel.text = self.viewModel.created_at(article.created_at)
            cell.titleLabel.text = article.title
            cell.tagsLabel.text = self.viewModel.tags(article.tags)
            cell.lileCountLabel.text = "\(article.likes_count)"
        }
        .disposed(by: disposeBag)
        
        // セルタップ
        tableView.rx.modelSelected(Article.self)
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
        
        // リフレッシュコントロール
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    self?.refreshControl.endRefreshing()
                    return
                }
                self.getArticleList()
                refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func initNavigationItem() {
        navigationItem.title = "ReadQiitaApp"
        
        let bookmarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), style: .plain, target: nil, action: nil)
        let searchModeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [bookmarkButton, searchModeButton]
        
        bookmarkButton.rx.tap.subscribe(onNext:  { [weak self] in
            let vc: BookmarkListViewController = BookmarkListViewController()
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            self?.navigationController?.present(navi, animated: true)
        })
        .disposed(by: disposeBag)
        
        
        searchModeButton.rx.tap.subscribe(onNext:  { [weak self] in
            guard let self else { return }
            AlertManager.showActionSheet(self, sender: searchModeButton, message: "検索モードを選択してください", actions: [
                UIAlertAction(title: "キーワード検索", style: .default,handler: { _ in
                    UserDefaults.standard.set(value: SearchMode.keyword.rawValue, key: .searchMode)
                    self.setSearchbarPlaceholder()
                    
                }),
                UIAlertAction(title: "タグ検索", style: .default,handler: { _ in
                    UserDefaults.standard.set(value: SearchMode.tag.rawValue, key: .searchMode)
                    self.setSearchbarPlaceholder()
                })
            ])
        })
        .disposed(by: disposeBag)

    }
    

    private func initSearchbar() {
        setSearchbarPlaceholder()
        searchbar.rx.text
            .orEmpty
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.viewModel.searchText.accept($0)
            })
            .disposed(by: disposeBag)
        
        searchbar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            guard let self else { return }
            self.getArticleList()
            self.view.endEditing(true)
        })
        .disposed(by: disposeBag)
    }
    
    
    private func setSearchbarPlaceholder() {
        if let mode: String = UserDefaults.standard.get(key: .searchMode) {
            switch mode {
            case SearchMode.keyword.rawValue:
                searchbar.placeholder = "検索するキーワードを入力してください"
            case SearchMode.tag.rawValue:
                searchbar.placeholder = "検索するタグ名を入力してください"
            default:
                searchbar.placeholder = "検索するキーワードを入力してください"
            }
        }
    }
    
    
    
}



// MARK: - API Request

extension ArticleListViewController {
    
    private func getArticleList() {
        let mode: String = UserDefaults.standard.get(key: .searchMode) ?? ""
        switch mode {
        case SearchMode.keyword.rawValue:
            self.getArticles()
        case SearchMode.tag.rawValue:
            self.getTagArticles()
        default:
            self.getArticles()
        }
    }
    
    
    private func getArticles() {
        Indicator.show(self.navigationController?.view)
        viewModel.getArticles(success: {
            Indicator.dismiss()
            if !self.viewModel.articles.value.isEmpty {
                self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
                self.noDataLabel.isHidden = true
            } else {
                self.noDataLabel.isHidden = false
            }
            
        },failure: { message, type in
            switch type {
            case .not_found:
                AlertManager.showAlert(self, type: .ok, message: message, didTapPositiveButton: { _ in
                    Indicator.dismiss()
                })
                
            default:
                AlertManager.showAlert(self, type: .retry, message: "再接続しますか?", didTapPositiveButton: { _ in
                    Indicator.dismiss()
                    self.getTagArticles()
                }, didTapNegativeButton: { _ in
                    Indicator.dismiss()
                })
            }
        })
    }
    
    private func getTagArticles() {
        Indicator.show(self.navigationController?.view)
        
        guard !viewModel.searchText.value.isEmpty else {
            getArticles()
            return
        }
        
        self.viewModel.getTagArticles(success: {
            Indicator.dismiss()
            if !self.viewModel.articles.value.isEmpty {
                self.tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: true)
                self.noDataLabel.isHidden = true
            } else {
                self.noDataLabel.isHidden = false
            }
            
        }, failure: { message, type in
            switch type {
            case .not_found:
                AlertManager.showAlert(self, type: .ok, message: message, didTapPositiveButton: { _ in
                    Indicator.dismiss()
                })
                
            default:
                AlertManager.showAlert(self, type: .retry, message: "再接続しますか?", didTapPositiveButton: { _ in
                    Indicator.dismiss()
                    self.getTagArticles()
                }, didTapNegativeButton: { _ in
                    Indicator.dismiss()
                })
            }
            
        })

    }
    
}
