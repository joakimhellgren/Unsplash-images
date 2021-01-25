//
//  HomeViewController.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2021-01-14.
//

import CoreData
import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    let isUserLoggedIn: Bool = false
    var user: String?
    
    // Core Data
    var favorites: [Favorite] = []
    
    private var showPopupMessage = true
    private let popupBackgroundView: UIView = {
        let popupBackgroundView = UIView()
        popupBackgroundView.alpha = 0
        return popupBackgroundView
    }()
    
    private let popupView: UIView = {
        let popupView = UIView()
        popupView.backgroundColor = .systemBackground
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = 12
        popupView.alpha = 0
        return popupView
    }()
    
    func showPopup(with title: String, message: String, on viewController: HomeViewController) {
        popupBackgroundView.frame = view.bounds
        view.addSubview(popupBackgroundView)
        
        let popupViewSize = popupBackgroundView.frame.size.width - (popupBackgroundView.frame.size.width / 7.125)
        popupView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: popupViewSize,
                                 height: popupViewSize + 128)
        popupView.center = CGPoint(x: view.center.x,
                                   y: view.center.y - (view.center.y / 2.5))
        view.addSubview(popupView)
        let titleLabel = UILabel(frame: CGRect(x: 16,
                                               y: 0,
                                               width: popupView.frame.size.width - 32,
                                               height: 54))
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle:  .title2)
        titleLabel.textAlignment = .center
        popupView.addSubview(titleLabel)
        let messageLabel = UILabel(frame: CGRect(x: 16,
                                                 y: 32,
                                                 width: popupView.frame.size.width - 32,
                                                 height: 64))
        messageLabel.numberOfLines = 0
        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.text = message
        messageLabel.textAlignment = .center
        popupView.addSubview(messageLabel)
        let emailField: UITextField = {
            let emailField = UITextField()
            emailField.frame = CGRect(x: 16,
                                      y: popupView.frame.size.height - 324,
                                      width: popupView.frame.size.width - 32,
                                      height: 40)
            emailField.placeholder = "Email"
            let lineView = UIView(frame: CGRect(x: 0,
                                                y: emailField.frame.size.height,
                                                width: emailField.frame.size.width,
                                                height: 1))
            lineView.alpha = 0.6
            lineView.backgroundColor = .opaqueSeparator
            emailField.addSubview(lineView)
            return emailField
        }()
        
        popupView.addSubview(emailField)
        
        let passwordField: UITextField = {
            let passwordField = UITextField()
            passwordField.frame = CGRect(x: 16,
                                         y: popupView.frame.size.height - 252,
                                         width: popupView.frame.size.width - 32,
                                         height: 40)
            passwordField.placeholder = "Password"
            passwordField.isSecureTextEntry = true
            let lineView = UIView(frame: CGRect(x: 0,
                                                y: passwordField.frame.size.height,
                                                width: passwordField.frame.size.width,
                                                height: 1))
            lineView.alpha = 0.6
            lineView.backgroundColor = .opaqueSeparator
            passwordField.addSubview(lineView)
            return passwordField
        }()
        popupView.addSubview(passwordField)
        
        let forgotPass = UIButton(type: .system,
                                  primaryAction: UIAction(title: "Forgot password?",
                                                          handler: { _ in print("forgot password button clicked") }))
        forgotPass.frame = CGRect(x: 16,
                                  y: popupView.frame.size.height - 200,
                                  width: popupView.frame.size.width - 32,
                                  height: 20)
        forgotPass.contentHorizontalAlignment = .trailing
        popupView.addSubview(forgotPass)
        
        let loginButton = UIButton(type: .system,
                                   primaryAction: UIAction(title: "Log in",
                                                           handler: { _ in self.dismissPopup() }))
        loginButton.frame = CGRect(x: 16,
                                   y: popupView.frame.size.height - 128,
                                   width: popupView.frame.size.width - 32,
                                   height: 48)
        loginButton.backgroundColor = .secondarySystemFill
        loginButton.layer.cornerRadius = 12
        popupView.addSubview(loginButton)
        
        let registerButton = UIButton(type: .system,
                                      primaryAction: UIAction(title: "Register",
                                                              handler: { _ in print("Register button clicked") }))
        registerButton.frame = CGRect(x: 16,
                                      y: popupView.frame.size.height - 64,
                                      width: popupView.frame.size.width - 32,
                                      height: 48)
        registerButton.backgroundColor = .secondarySystemFill
        registerButton.layer.cornerRadius = 12
        popupView.addSubview(registerButton)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.popupBackgroundView.alpha = 1
            self.popupView.alpha = 1
        })
        
    }
    
    func dismissPopup() {
        UIView.animate(withDuration: 0.25, animations: {
            self.popupView.alpha = 0
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.popupBackgroundView.alpha = 0
                }, completion: { done in
                    if done {
                        self.popupView.removeFromSuperview()
                        self.popupBackgroundView.removeFromSuperview()
                        self.scrollView.bounces = true
                        self.addUserView(with: "Joakim", on: self)
                        UIView.animate(withDuration: 0.25, animations: {
                            self.navigationController?.navigationBar.alpha = 1
                        })
                    }
                })
            }
        })
        
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: Collection view configuration
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.alpha = 0
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FavoritesCollectionViewCell.self,
                                forCellWithReuseIdentifier: FavoritesCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    //MARK: DiffableDataSource configuration
    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, Favorite> = {
        // cell config
        let dataSource = UICollectionViewDiffableDataSource<Int, Favorite>(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCollectionViewCell.identifier, for: indexPath) as! FavoritesCollectionViewCell
            let username = self.favorites[indexPath.row].value(forKey: "user") as? String
            let imageUrl = self.favorites[indexPath.row].value(forKey: "image") as? String
            if let safeUsername = username,
               let safeImageUrl = imageUrl {
                cell.configure(label: safeUsername, image: safeImageUrl)
            } else {
                let errorLabel = "error getting user"
                let errorImg = "https://cdn.shopify.com/s/files/1/0533/2089/files/placeholder-images-image_large.png?format=jpg&quality=90&v=1530129081"
                cell.configure(label: errorLabel, image: errorImg)
            }
            return cell
        }
        return dataSource
    }()
    
    
    
    func update(with items: [Favorite]) {
        // compare new data with any existing data and replace where necessary.
        var snapshot = NSDiffableDataSourceSnapshot<Int, Favorite>()
        snapshot.appendSections([0])
        snapshot.appendItems(favorites, toSection: 0)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    private let userView: UIView = {
        let userView = UIView()
        userView.layer.masksToBounds = true
        userView.layer.cornerRadius = 12
        userView.alpha = 0
        return userView
    }()
    
    private let favoritesView: UIView = {
        let favoritesView = UIView()
        favoritesView.layer.masksToBounds = true
        favoritesView.layer.cornerRadius = 12
        favoritesView.alpha = 0
        favoritesView.backgroundColor = .systemFill
        return favoritesView
    }()
    
    
    func addUserView(with username: String, on viewController: HomeViewController) {
        
        userView.frame = CGRect(x: 16, y: 0, width: view.frame.width, height: view.frame.height - 32)
        userView.center = CGPoint(x: view.center.x, y: view.center.y)
        view.addSubview(userView)
        
        let usernameLabel = UILabel(frame: CGRect(x: 16, y: 16, width: view.frame.size.width - 32, height: 54))
        usernameLabel.text = "Welcome back, \(username)"
        usernameLabel.font = .preferredFont(forTextStyle:  .title2)
        usernameLabel.textAlignment = .left
        userView.addSubview(usernameLabel)
        
        collectionView.frame = CGRect(x: 16, y: 128, width: userView.frame.width - 32, height: userView.frame.height - 32)
        userView.addSubview(collectionView)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.userView.alpha = 1
            self.collectionView.alpha = 1
        })
    }
    
    
    // this method is unused, but remains here for future implementation
    func dismissUserView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.userView.alpha = 0
        }, completion: { done in
            if done {
                self.userView.removeFromSuperview()
            }
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //resetCoreData()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: true)
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
        do {
            favorites = try managedContext.fetch(fetchRequest)
            update(with: favorites)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //1
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let fav = favorites[indexPath.row]
        do {
            persistentContainer.viewContext.delete(fav)
            try persistentContainer.viewContext.save()
            favorites.remove(at: indexPath.row)
            update(with: favorites)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // method unsused,  but useful for purging during development.
    func resetCoreData() {
        let fetchRequest =
        NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        // fetchRequest.returnsObjectsAsFaults = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        do {
        try persistentContainer.viewContext.execute(deleteRequest)
        } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if showPopupMessage == true {
            tabBarController?.tabBar.isHidden = true
            switch isUserLoggedIn {
            case false:
                showPopup(with: "Hello, stranger.", message: "log in to continue.", on: self)
            case true:
                return
            }
            showPopupMessage = false
        }
    }
}

