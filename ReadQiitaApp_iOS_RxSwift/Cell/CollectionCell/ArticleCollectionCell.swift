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
