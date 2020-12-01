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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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



/*
 
 // MARK: Does same thing as above uncommented code block. I am not sure which one is considered best practice for my use case.
 extension UIImageView {
     func dlImg(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
         DispatchQueue.main.async { [weak self] in
             self?.backgroundColor = .lightGray
             UIView.animate(withDuration: 0.5) {
                 self?.alpha = 0.25
             }
         }
         URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
     }

     func load(url: URL) {
         
         //print("Download started")
         dlImg(from: url) { data, response, error in
             guard let data = data, error == nil else { return }
             //print(response?.suggestedFilename ?? url.lastPathComponent)
             //print("Donwload finished")
             DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                 UIView.animate(withDuration: 0.5) {
                     self?.image = UIImage(data: data)
                     self?.alpha = 1
                 }
                 
             }
         }
     }
 }




 
 */
