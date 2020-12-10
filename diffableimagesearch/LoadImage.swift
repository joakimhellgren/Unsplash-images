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
        // reset data source for dequeued cell (see config method in CollectionViewCell.swift)
        image = nil
        // make placeholder background
        // to indicate that something is loading
        DispatchQueue.main.async {
            self.backgroundColor = .darkGray
        }
        
        // prevent multple sessions of task for the same image.
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
            
            guard
                let data = data,
                let newImage = UIImage(data: data)
            else {
                print("couldn't load image from url: \(url)")
                return
            }
            
            // cache DL'ed image.
            imageCache.setObject(newImage, forKey: url.absoluteString as AnyObject)
            
            DispatchQueue.main.async {
                self.image = newImage
            }
        }
        
        task?.resume()
    }
    
}
