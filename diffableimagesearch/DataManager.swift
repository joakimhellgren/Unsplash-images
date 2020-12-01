//
//  DataManager.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-30.
//

import Foundation

class DataManager {
    let apiURL = "https://api.unsplash.com/search/photos?client_id=aCjNILUQzy5m2pMEiE1Ax9U4-_T9o6KPvKORnwfOxPQ"
    func fetch(page: Int, searchTerm: String, callback: @escaping (Images) -> ()) {
  
        
        let urlString = "\(apiURL)&query=\(searchTerm)&page=\(page)&per_page=25"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    let decoder = JSONDecoder()
                    do {
                        
                        let decodedData = try decoder.decode(Images.self, from: safeData)
                        DispatchQueue.main.async {
                            if decodedData.results.count == 0 {
                                print("no results returned because there was nothing found in the database.")
                            }
                            callback(decodedData)
                      
                        }
                       
                    } catch {
                        print(error)
                    }
                }
            }
            task.resume()
            
        }
    }
}
