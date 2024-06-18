//
//  MoviesSearchLoader.swift
//  DiagnalApp
//
//  Created by Muthulingam on 17/06/24.
//

import Foundation

protocol MoviesSearchLoader{
    typealias Result = Swift.Result<[MoviesCard], Error>
    
    func searchMovies(searchText: String, completion: @escaping (Result) -> Void)
}
