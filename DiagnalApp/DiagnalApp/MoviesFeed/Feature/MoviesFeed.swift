//
//  MoviesFeed.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

struct MoviesFeed: Hashable{
    let title: String
    let totalContentItems: Int
    let pageNum: Int
    let pageSize: Int
    let items: [MoviesCard]
    
    init(title: String, totalContentItems: Int, pageNum: Int, pageSize: Int, items: [MoviesCard]) {
        self.title = title
        self.totalContentItems = totalContentItems
        self.pageNum = pageNum
        self.pageSize = pageSize
        self.items = items
    }
}

struct MoviesCard: Hashable{
    let name: String
    let posterImage: String
    
    init(name: String, posterImage: String) {
        self.name = name
        self.posterImage = posterImage
    }
}
