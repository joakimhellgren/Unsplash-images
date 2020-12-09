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
        
        task?.resume()
    }
    
}
