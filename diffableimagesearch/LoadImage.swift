//
//  LoadImage.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-29.
//

import UIKit

// MARK: Image loader
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            DispatchQueue.main.async {
                // presents cells that have not yet completed downloading
                // with a darker background color to make the user aware that something is loading.
                UIView.animate(withDuration: 0.5) {
                    self?.alpha = 0.25
                    self?.backgroundColor = .lightGray
                }
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        // when the image has been loaded we animate the change, like so:
                       
                        DispatchQueue.main.async {
                            self?.image = image
                            UIView.animate(withDuration: 0.5, animations: {
                                self?.alpha = 1
                            })
                        }
                    }
                }
            }
            
        }
    }
}

