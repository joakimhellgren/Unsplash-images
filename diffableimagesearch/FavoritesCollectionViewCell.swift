//
//  FavoritesCollectionViewCell.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2021-01-19.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    
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
        imageView.layer.cornerRadius = 6
        imageView.alpha = 1
        return imageView
    }()
    
    public func configure(label: String?, image: String?) {
        myLabel.text = label
        guard let safeImage = image else {
            return myImageView.image = UIImage(systemName: "icloud.slash")
        }
        guard let url = URL(string: safeImage) else {
            return
        }
        myImageView.loadImage(from: url)
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        myLabel.text = nil
        myImageView.image = nil
        myImageView.alpha = 1
    }
}
