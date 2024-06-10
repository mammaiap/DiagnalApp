//
//  MoviesFeedLoader.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

struct PagedMoviesRequest {
    let page: Int
    
    init(page: Int) {
        self.page = page
    }
}

protocol MoviesFeedLoader {
    
    typealias Result = Swift.Result<MoviesFeed, Error>
    
    func load(_ req: PagedMoviesRequest, completion: @escaping (Result) -> Void)
    
}
