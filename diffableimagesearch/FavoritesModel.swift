//
//  FavoritesModel.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2021-01-24.
//

import Foundation

struct Favorites: Codable, Identifiable {
    var id = UUID()
    
    let user: String
    let image: String
}
