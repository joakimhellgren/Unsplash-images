//
//  DetailViewController.swift
//  imgsrch
//
//  Created by Joakim Hellgren on 2020-11-18.
//

import UIKit

class DetailsViewController: UIViewController {
    
    private var detailsViewController: UIScrollView?
    private let activityIndicator = UIActivityIndicatorView()
    private let myImageView: CustomImageView = {
        let imageView = CustomImageView()
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
        detailsViewController = UIScrollView()
        guard let detailsViewController = detailsViewController else {
            return
        }
        detailsViewController.backgroundColor = .systemBackground
        detailsViewController.frame = view.bounds
        detailsViewController.alwaysBounceVertical = true
        view.addSubview(detailsViewController)
        myImageView.frame = CGRect(x: 16, y: 16, width: detailsViewController.frame.size.width - 32, height: detailsViewController.frame.size.width - 4)
        dateLabel.frame = CGRect(x: 16, y: myImageView.frame.height + 16, width: detailsViewController.frame.size.width - 32, height: 50)
        descriptionLabel.frame = CGRect(x: 16, y: myImageView.frame.height + 48, width: detailsViewController.frame.size.width - 32, height: 50)
        activityIndicator.frame = CGRect(x: 16, y: descriptionLabel.frame.height + 16, width: detailsViewController.frame.size.width - 32, height: detailsViewController.frame.size.width - 4)
        detailsViewController.addSubview(activityIndicator)
        detailsViewController.addSubview(dateLabel)
        detailsViewController.addSubview(myImageView)
        detailsViewController.addSubview(descriptionLabel)
    }
    
    
    
    // 2017-12-28T11:39:32-05:00
    
    
    public func configure(user: String, image: URL, date: String, description: String) {
   
        let dateString = "2016-12-15T22:10:00Z"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let datee = dateFormatter.date(from: dateString)

        dateFormatter.dateStyle = .medium
        if let fdate = datee {
            dateLabel.text = dateFormatter.string(from: fdate)
        } else {
            dateLabel.text = "error"
        }
        
        
        activityIndicator.startAnimating()
        title = user
        myImageView.loadImage(from: image)
       
        descriptionLabel.text = description
    }
}

