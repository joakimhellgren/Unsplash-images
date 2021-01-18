//
//  LoadImage.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-29.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    var task: URLSessionTask?
    func loadImage(from url: URL) {
        // set image to nil in case there was already an image assigned.
        image = nil
        // make placeholder background
        // to indicate that something is loading
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = .darkGray
            }
        }
        
        // prevent multple sessions of the same task.
        if let task = task {
            task.cancel()
        }
        
        // prevent image from loading/downloading if it has already been cached.
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            // set image to cached image
            self.image = imageFromCache
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { ( data, response, error) in
            guard let data = data, let newImage = UIImage(data: data) else {
                //print("couldn't load image from url: \(url)")
                return
            }
            
            // cache DL'ed image.
            imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.image = newImage
                    self.alpha = 1
                }
            }
        }
        
        task?.resume()
    }
    
}



