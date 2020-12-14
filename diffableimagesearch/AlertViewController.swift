//
//  AlertViewController.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-12-14.
//

import UIKit

class AlertViewController {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    
    private let backgroundView: UIView = {
       let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let alertView: UIView = {
       let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()
    
    private var myTargetView: UIView?
    
    func showAlert(with title: String, message: String, on viewController: ViewController) {
        guard let targetView = viewController.view else {
            return
        }
        myTargetView = targetView
        
        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)
        targetView.addSubview(alertView)
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: targetView.frame.size.width - 80,
                                 height: 300)
        
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 80))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        alertView.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                               y: 80,
                                               width: alertView.frame.size.width,
                                               height: 170))
        
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.textAlignment = .left
        
        alertView.addSubview(messageLabel)
        
        let button = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height - 50, width: alertView.frame.size.width, height: 50))
        
        
        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(button)
        
        
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alertView.center = CGPoint(x: 210, y: 300)
                })
            }
        })
    }
    
    @objc func dismissAlert() {
        
        guard let targetView = myTargetView else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.size.width - 80, height: 300)
        }, completion: { done in
            if done {
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundView.alpha = 0
                }, completion: { done in
                    if done {
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                })
            }
        })
    }
    
    
}
