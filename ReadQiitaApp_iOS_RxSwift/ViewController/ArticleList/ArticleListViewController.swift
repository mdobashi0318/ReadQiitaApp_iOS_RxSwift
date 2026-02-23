import UIKit
import RxSwift
import RxCocoa

final class ArticleListViewController: UIViewController {
    
    enum DispMode: String {
        case list
        case grid
        
        var title: String {
            return switch self {
            case .list:
                "リスト"
            case .grid:
                "グリッド"
            }
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var searchbar: UISearchBar!
    @IBOutlet private weak var noDataLabel: UILabel!
    private var collectionView: UICollectionView!
    private var dispModeButton: UIBarButtonItem!
    private let disposeBag = DisposeBag()
    private let viewModel = ArticleListViewModel()
    private let tableRefreshControl = UIRefreshControl()
    private let collectionRefreshControl = UIRefreshControl()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Article>! = nil
    private var dispMode: DispMode = .list {
        didSet {
            let isList = dispMode == .list
            containerView.isHidden = isList
            tableView.isHidden = !isList
        }
    }
    private let listImage = UIImage(systemName: "list.bullet")
    private let squareImage = UIImage(systemName: "square.grid.2x2")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispMode = DispMode(rawValue: UserDefaults.standard.get(key: .dispMode) ?? DispMode.list.rawValue) ?? .list
        getArticleList()
        initNavigationItem()
        initTableView()
        initSearchbar()
        configure()
        configureDataSource()
    }
    
    private func initNavigationItem() {
        navigationItem.title = "ReadQiitaApp"
        
        let bookmarkButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "bookmark.fill"), style: .plain, target: nil, action: nil)
        let searchModeButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: nil, action: nil)
        dispModeButton = UIBarButtonItem(image: dispMode == .list ? listImage : squareImage,
                                         style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [bookmarkButton, searchModeButton, dispModeButton]
        
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
        
        dispModeButton.rx.tap.subscribe(onNext:  { [weak self] in
            guard let self else { return }
            AlertManager.showActionSheet(self, sender: searchModeButton, message: "表示モードを選択してください", actions: [
                UIAlertAction(title: DispMode.list.title, style: .default,handler: { _ in
                    UserDefaults.standard.set(value: DispMode.list.rawValue, key: .dispMode)
                    self.dispMode = .list
                    self.dispModeButton.image = self.listImage
                }),
                UIAlertAction(title: DispMode.grid.title, style: .default,handler: { _ in
                    UserDefaults.standard.set(value: DispMode.grid.rawValue, key: .dispMode)
                    self.dispModeButton.image = self.squareImage
                    self.dispMode = .grid
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
    
    private func pushArticleViewController(_ article: Article) {
        let vc: ArticleViewController = ArticleViewController()
        vc.id = article.id
        vc.articleTitle = article.title
        vc.url = article.url
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


// MARK: - UITableView

extension ArticleListViewController {
    
    private func initTableView() {
        tableView.register(UINib(nibName: "ArticleCell", bundle: nil), forCellReuseIdentifier: "ArticleCell")
        tableView.refreshControl = tableRefreshControl
        
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
                guard let self else { return }
                self.pushArticleViewController(article)
            })
            .disposed(by: disposeBag)
        
        // 選択状態のハイライト解除
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        })
        .disposed(by: disposeBag)
        
        // リフレッシュコントロール
        tableRefreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    self?.tableRefreshControl.endRefreshing()
                    return
                }
                self.getArticleList()
                tableRefreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - UICollectionView

extension ArticleListViewController {
    
    enum Section {
        case article
    }
    
    func configure() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewCompositionalLayout(section: articleLayout()))
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
        
        collectionView.refreshControl = collectionRefreshControl
        // リフレッシュコントロール
        collectionRefreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                guard let self else {
                    self?.collectionRefreshControl.endRefreshing()
                    return
                }
                self.getArticleList()
                collectionRefreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func articleLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(210))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ArticleCollectionCell, Article>(cellNib: UINib(nibName: "ArticleCollectionCell", bundle: nil)) { cell, indexPath, identifiable in
            cell.setView(self.viewModel.articles.value[indexPath.row])
        }
        dataSource = UICollectionViewDiffableDataSource<Section, Article>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, identifier: Article) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }
        
        collectionView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let self else { return }
            self.pushArticleViewController(self.viewModel.articles.value[indexPath.row])
        })
        .disposed(by: disposeBag)
        
        
        viewModel.articles
            .subscribe(onNext: { items in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Article>()
                snapshot.appendSections([.article])
                snapshot.appendItems(items)
                self.dataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposeBag)
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
                self.collectionView.setContentOffset(.zero, animated: true)
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
                    self.getArticles()
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
                self.collectionView.setContentOffset(.zero, animated: true)
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
