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
        
        // bind our parent view
        myTargetView = targetView
        // tell background vc to mimic dimensions @ parent vc.
        backgroundView.frame = targetView.bounds
        // add transparent background to parent vc
        targetView.addSubview(backgroundView)
        // set dimensions of popup view
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: targetView.frame.size.width - 80,
                                 height: 300)
        alertView.center = CGPoint(x: 210, y: 250)
        alertView.alpha = 0
        // add popup view to parent vc
        targetView.addSubview(alertView)
        
        // configure title label for popup view
        let titleLabel = UILabel(frame: CGRect(x: 0,
                                               y: 0,
                                               width: alertView.frame.size.width,
                                               height: 80))
        
        // set title labels text to func parameter input "title"
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle:  .title2)
        titleLabel.textAlignment = .center
        // add title label to popup view
        alertView.addSubview(titleLabel)
        // configure title label for popup view
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                               y: 80,
                                               width: alertView.frame.size.width,
                                               height: 170))
        
        messageLabel.numberOfLines = 0
        // set message labels text to func parameter input "message"
        messageLabel.text = message
        messageLabel.textAlignment = .center
        // add message label to popup view
        alertView.addSubview(messageLabel)
        
        // configure dismiss button for popup view
        let button = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height - 50, width: alertView.frame.size.width, height: 50))
        button.setTitle("Thanks, I guess?", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(button)
        
        UIView.animate(withDuration: 0.25, animations: {
            // animate background opacity / color effect on our transparent background
            self.backgroundView.alpha = Constants.backgroundAlphaTo
        }, completion: { done in
            if done {
                // animate position of popup view when initial background animation has finished running.
                UIView.animate(withDuration: 0.25, animations: {
                    //self.alertView.center = CGPoint(x: 210, y: 300)
                    self.alertView.alpha = 1
                })
            }
        })
    }
    
    @objc func dismissAlert() {
        
        guard let targetView = myTargetView else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            //self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.size.width - 80, height: 300)
            self.alertView.alpha = 0
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
