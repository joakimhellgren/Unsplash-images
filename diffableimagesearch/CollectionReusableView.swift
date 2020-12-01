//
//  CollectionReusableView.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-29.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityIndicator)
        activityIndicator.frame = bounds
        addSubview(titleLabel)
        titleLabel.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(with title: String, loading: Bool) {
        titleLabel.text = title
        titleLabel.textAlignment = .center
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}



/*
titleLabel.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
    titleLabel.topAnchor.constraint(equalTo: topAnchor),
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
    titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
])
*/
