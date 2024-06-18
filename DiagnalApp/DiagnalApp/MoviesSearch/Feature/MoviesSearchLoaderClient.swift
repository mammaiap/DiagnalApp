//
//  MoviesSearchLoaderClient.swift
//  DiagnalApp
//
//  Created by Muthulingam on 17/06/24.
//

import Foundation

protocol MoviesSearchLoaderClient{
    typealias Result = Swift.Result<[MoviesCard], Error>
    
    func getSearchedMovies(searchText: String, inputMovies: [MoviesCard], completion: @escaping (Result) -> Void)
}
