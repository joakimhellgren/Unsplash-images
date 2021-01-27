//
//  DetailViewController.swift
//  imgsrch
//
//  Created by Joakim Hellgren on 2020-11-18.
//

import CoreData
import UIKit

class DetailsViewController: UIViewController {
    
    // Core Data Model
    public var favorites: [Favorite] = []
    
    // save image data to favorites with Core Data
    func save(user: String, image: String, date: String, description: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: managedContext)!
        let favorite = Favorite(entity: entity, insertInto: managedContext)
        let id = UUID()
        favorite.setValue(id, forKey: "id")
        favorite.setValue(user, forKey: "user")
        favorite.setValue(image, forKey: "image")
        favorite.setValue(date, forKey: "date")
        favorite.setValue(description, forKey: "desc")
        do {
            try managedContext.save()
            favorites.append(favorite)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private var detailsViewController: UIScrollView?
    private let activityIndicator = UIActivityIndicatorView()
    private let myImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            tap.numberOfTapsRequired = 2
            view.addGestureRecognizer(tap)
    }
    

    func formatDate(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formattedDate = dateFormatter.date(from: date)
        dateFormatter.dateStyle = .medium
        if let safeDate = formattedDate {
            dateLabel.text = dateFormatter.string(from: safeDate)
        } else {
            dateLabel.text = "error formatting the date"
        }
    }
    
    var currentImageData: Image?
    
    public func configure(data: Image) {
        formatDate(date: data.created_at)
        activityIndicator.startAnimating()
        title = data.user.username
        myImageView.loadImage(from: data.urls.regular)
        if let description = data.description {
            descriptionLabel.text = "\"" + description + "\""
        } else {
            descriptionLabel.text = "\"" + "no description found" + "\""
        }
        currentImageData = data
    }
    
    
    @objc func doubleTapped() {
        guard let data = currentImageData else { return }
        save(user: data.user.username,
                image: data.urls.small.absoluteString,
                date: data.created_at,
                description: data.description ?? "no description found")
        UIView.animate(withDuration: 0.2, animations: {
            self.myImageView.alpha = 0.5
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.2) {
                    self.myImageView.alpha = 1
                }
            }
        })
        print("Added to <3")
    }
    
    
}

