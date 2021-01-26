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
    
    // Core Data
    var favorites: [Favorite] = []
    
    //MARK: - collection view diffable data source configuration
    private lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, Favorite> = {
        // cell config
        let dataSource = UICollectionViewDiffableDataSource<Int, Favorite>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesCollectionViewCell.identifier, for: indexPath) as? FavoritesCollectionViewCell else {
                return UICollectionViewCell()
            }
            let username = self.favorites[indexPath.row].value(forKey: "user") as? String
            let imageUrl = self.favorites[indexPath.row].value(forKey: "image") as? String
            cell.configure(label: username, image: imageUrl)
            return cell
        }
        return dataSource
    }()
    
    
    func update(with items: [Favorite]) {
        // compare new data with any existing data in diff data source and update any changes.
        var snapshot = NSDiffableDataSourceSnapshot<Int, Favorite>()
        snapshot.appendSections([0])
        snapshot.appendItems(favorites, toSection: 0)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Collection view configuration
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.alpha = 0
        collectionView.backgroundColor = .secondarySystemBackground
        
        collectionView.layer.cornerRadius = 12
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(FavoritesCollectionViewCell.self,
                                forCellWithReuseIdentifier: FavoritesCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    // tapping a cell in the collection view removes it from our Diff data source + core data
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let fav = favorites[indexPath.row]
        do {
            persistentContainer.viewContext.delete(fav)
            try persistentContainer.viewContext.save()
            favorites.remove(at: indexPath.row)
            update(with: favorites)
        } catch let error as NSError {
            print("Could not save changes. \(error), \(error.userInfo)")
        }
    }
    
    
    // MARK: - Screen states
    var user: String?
    var showPopupMessage = true
    var isUserLoggedIn = false
    
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
                        self.isUserLoggedIn = true
                        UIView.animate(withDuration: 0.25, animations: {
                            self.navigationController?.navigationBar.alpha = 1
                            self.tabBarController?.tabBar.isHidden = false
                        })
                    }
                })
            }
        })
    }
    
    
    func addUserView(with username: String, on viewController: HomeViewController) {
        
        // add a text that welcomes the user with their user name
        let usernameLabel = UILabel(frame: CGRect(x: 16, y: 16, width: view.frame.size.width - 32, height: 54))
        usernameLabel.text = "Welcome back, \(username)"
        usernameLabel.font = .preferredFont(forTextStyle:  .title1)
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)
        
        collectionView.frame = CGRect(x: 16, y: 128, width: view.frame.width - 32, height: view.frame.width - 32)
        view.addSubview(collectionView)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView.alpha = 1
        })
    }
    
    //MARK: - et al
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: true)
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // retrieve Core Data data and update diff data source with Core Data data
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
    
    override func viewDidAppear(_ animated: Bool) {
        // check if user is logged in or not (placeholder implementation for now)
        switch isUserLoggedIn {
        case false:
            tabBarController?.tabBar.isHidden = true
            showPopup(with: "Hello, stranger.", message: "log in to continue.", on: self)
        case true:
            tabBarController?.tabBar.isHidden = false
        }
    }
}

