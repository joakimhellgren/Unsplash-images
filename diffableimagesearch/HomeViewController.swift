//
//  HomeViewController.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2021-01-14.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    
    let isUserLoggedIn: Bool = false
    var user: String?
    
    private var showPopupMessage = true
    private let popupBackgroundView: UIView = {
        let popupBackgroundView = UIView()
        popupBackgroundView.alpha = 0
        return popupBackgroundView
    }()
    
    private let popupView: UIView = {
        let popupView = UIView()
        popupView.backgroundColor = .white
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
    
    
    
    private let userView: UIView = {
        let userView = UIView()
        userView.backgroundColor = .white
        userView.layer.masksToBounds = true
        userView.layer.cornerRadius = 12
        userView.alpha = 0
        return userView
    }()
    
    
    func addUserView(with username: String, on viewController: HomeViewController) {
        userView.frame = CGRect(x: 16,
                                y: 0,
                                width: view.frame.width,
                                height: view.frame.height - 32)
        userView.center = CGPoint(x: view.center.x,
                                  y: view.center.y)
        view.addSubview(userView)
        
        let usernameLabel = UILabel(frame: CGRect(x: 16,
                                                  y: 128,
                                                  width: view.frame.size.width - 32,
                                                  height: 54))
        usernameLabel.text = "Welcome back, \(username)."
        usernameLabel.font = .preferredFont(forTextStyle:  .title3)
        usernameLabel.textAlignment = .center
        userView.addSubview(usernameLabel)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.userView.alpha = 1
        })
    }
    
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
        scrollView.backgroundColor = .systemBackground

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if showPopupMessage == true {
            //collectionView.bounces = false
            //navigationController?.navigationBar.alpha = 0
            //searchController.searchBar.isUserInteractionEnabled = false
            tabBarController?.tabBar.isHidden = true
            switch isUserLoggedIn {
            case false:
                let RGAppNames = [
                    "Unsplashify",
                    "Imagify",
                    "unSplashed",
                    "PicSearchify",
                    "Picstagram",
                    "Unsplashtagram",
                    "Splashify"
                ]
                guard let randomAppName = RGAppNames.randomElement() else { return }
                showPopup(with: "Hello, stranger.",
                          message: "Welcome to \(randomAppName), log in to continue.",
                          on: self)
            case true:
                return
            }
            showPopupMessage = false
        }
    }


}