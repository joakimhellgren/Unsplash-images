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

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    var task: URLSessionTask!
    
    func loadImage(from url: URL) {
        image = nil
        
        if let task = task {
            task.cancel()
        }
        
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { ( data, response, error) in
            
            guard
                let data = data,
                let newImage = UIImage(data: data)
            else {
                print("couldn't load image from url: \(url)")
                return
            }
            
            imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            
            DispatchQueue.main.async {
                self.image = newImage
            }
        }
        
        task.resume()
    }
    
}
