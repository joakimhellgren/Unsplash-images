//
//  Images.swift
//  diffableimagesearch
//
//  Created by Joakim Hellgren on 2020-11-26.
//

import Foundation

struct Images: Decodable {
    let total: Int
    let total_pages: Int
    let results: [Image]
}

struct Image: Decodable, Hashable {
    let id: String
    let created_at: String
    let description: String?
    let urls: Urls
    let user: Users
}

struct Urls: Decodable, Hashable {
    let small: URL
    let regular: URL
}

struct Users: Decodable, Hashable {
    let username: String
}
