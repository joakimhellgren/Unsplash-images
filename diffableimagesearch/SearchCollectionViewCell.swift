//
//  CollectionViewCell.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-28.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "cell"
    private var myLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    private var myImageView: CustomImageView = {
        let imageView = CustomImageView()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        
        imageView.alpha = 1
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(myImageView)
        contentView.addSubview(myLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let label = aDecoder.decodeObject() as? UILabel,
           let img = aDecoder.decodeObject() as? CustomImageView {
            self.myLabel = label
            self.myImageView = img
        } else {
            return nil
        }
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myLabel.frame = CGRect(x: 8, y: contentView.frame.size.height - 50, width: contentView.frame.size.width - 16, height: 50)
        myImageView.frame = CGRect(x: 8, y: 0, width: contentView.frame.size.width - 16, height: contentView.frame.size.height - 50)
    }
    
    public func configure(label: String, image: URL) {
        myLabel.text = label
        myImageView.loadImage(from: image)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myLabel.text = nil
        myImageView.image = nil
        myImageView.alpha = 1
    }
    
    // feedback animation when user taps on a cell
    override var isHighlighted: Bool {
        didSet {
            toggleIsHighlighted()
        }
    }
    
    func toggleIsHighlighted() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = self.isHighlighted ? 0.9 : 1.0
            self.transform = self.isHighlighted ? CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97) : CGAffineTransform.identity
        })
    }
    
}
