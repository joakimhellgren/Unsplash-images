//
//  DetailViewController.swift
//  imgsrch
//
//  Created by Joakim Hellgren on 2020-11-18.
//

import UIKit

class DetailsViewController: UIViewController {
    
    private var detailsViewController: UIView?
    
    private let activityIndicator = UIActivityIndicatorView()
    
    private let myImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsViewController = UIView()
        guard let detailsViewController = detailsViewController else {
            return
        }
        
        detailsViewController.backgroundColor = .systemBackground
        detailsViewController.frame = view.bounds
        view.addSubview(detailsViewController)
        myImageView.frame = CGRect(x: 2, y: 148, width: detailsViewController.frame.size.width - 4, height: detailsViewController.frame.size.width - 4)
        dateLabel.frame = CGRect(x: 2, y: detailsViewController.frame.size.width / 0.75, width: detailsViewController.frame.size.width - 2, height: 50)
        descriptionLabel.frame = CGRect(x: 0, y: detailsViewController.frame.size.width / 0.70, width: detailsViewController.frame.size.width, height: 50)
        activityIndicator.frame = CGRect(x: 2, y: 148, width: detailsViewController.frame.size.width - 4, height: detailsViewController.frame.size.width - 4)
        detailsViewController.addSubview(activityIndicator)
        detailsViewController.addSubview(dateLabel)
        detailsViewController.addSubview(myImageView)
        detailsViewController.addSubview(descriptionLabel)
    }
    
    
    public func configure(user: String, image: URL, date: String, description: String) {
        activityIndicator.startAnimating()
        title = user
        myImageView.load(url: image)
        dateLabel.text = date
        descriptionLabel.text = description
    }
    
  


}

