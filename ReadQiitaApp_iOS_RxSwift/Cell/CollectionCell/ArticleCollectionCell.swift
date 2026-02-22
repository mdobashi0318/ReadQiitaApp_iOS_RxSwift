import UIKit

final class ArticleCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var contentsView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var organizationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var tagsLabel: UILabel!
    @IBOutlet private weak var likeCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentsView.layer.cornerRadius = 6
        contentsView.layer.borderColor = UIColor(named: "collectionCorder")?.cgColor
        contentsView.layer.borderWidth = 0.5
        
        contentsView.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        contentsView.layer.shadowColor = UIColor.black.cgColor
        contentsView.layer.shadowOpacity = 0.2
        contentsView.layer.shadowRadius = 8
    }
    
    func setView(_ article: Article) {
        userNameLabel.text = "@\(article.user.id)"
        organizationLabel.text = article.user.organization
        dateLabel.text = article.formatCreatedAt()
        titleLabel.text = article.title
        tagsLabel.text = article.joinedTagNames()
        likeCountLabel.text = "\(article.likes_count)"
    }
    
}
