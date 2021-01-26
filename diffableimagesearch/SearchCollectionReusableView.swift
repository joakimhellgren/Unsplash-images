//
//  CollectionReusableView.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-29.
//

import UIKit

class SearchCollectionReusableView: UICollectionReusableView {
    
    private var titleLabel = UILabel()
    private var activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityIndicator)
        activityIndicator.frame = bounds
        addSubview(titleLabel)
        titleLabel.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let label = aDecoder.decodeObject() as? UILabel,
           let loader = aDecoder.decodeObject() as? UIActivityIndicatorView {
            self.titleLabel = label
            self.activityIndicator = loader
        } else {
            return nil
        }
        super.init(coder: aDecoder)
    }
    
    func fill(with title: String, loading: Bool) {
        titleLabel.text = title
        titleLabel.textAlignment = .center
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

