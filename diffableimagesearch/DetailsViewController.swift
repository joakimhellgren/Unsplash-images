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
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 10
        label.font = .preferredFont(forTextStyle: .caption1)
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
        myImageView.frame = CGRect(x: 16, y: 16, width: detailsViewController.frame.size.width - 32, height: detailsViewController.frame.size.width)
        dateLabel.frame = CGRect(x: 16, y: myImageView.frame.height + 16, width: detailsViewController.frame.size.width - 32, height: 50)
        descriptionLabel.frame = CGRect(x: 16, y: myImageView.frame.height + 64, width: detailsViewController.frame.size.width - 32, height: 50)
        activityIndicator.frame = CGRect(x: 16, y: descriptionLabel.frame.height + 16, width: detailsViewController.frame.size.width - 32, height: detailsViewController.frame.size.width - 4)
        detailsViewController.addSubview(activityIndicator)
        detailsViewController.addSubview(dateLabel)
        detailsViewController.addSubview(myImageView)
        detailsViewController.addSubview(descriptionLabel)
    }
    
    
    
    // 2017-12-28T11:39:32-05:00
    
    private func formatDate(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formattedDate = dateFormatter.date(from: date)
        dateFormatter.dateStyle = .medium
        if let safeDate = formattedDate {
            self.dateLabel.text = dateFormatter.string(from: safeDate)
        } else {
            dateLabel.text = "error formatting the date"
        }
    }
    
    public func configure(user: String, image: URL, date: String, description: String) {
        formatDate(date: date)
        activityIndicator.startAnimating()
        title = "Image by \(user)"
        myImageView.loadImage(from: image)
        descriptionLabel.text = "\"" + description + "\""
    }
}

