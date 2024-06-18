//
//  MoviesFilterLoader.swift
//  DiagnalApp
//
//  Created by Muthulingam on 17/06/24.
//

import Foundation

class MoviesFilterLoader: MoviesSearchLoader{
    
    private let inputMovies: [MoviesCard]
    private let client: MoviesSearchLoaderClient
    
    init(inputMovies: [MoviesCard], client: MoviesSearchLoaderClient) {
        self.inputMovies = inputMovies
        self.client = client
    }   
    
    enum Error: Swift.Error{
        case searchNotFoundError
    }
    
    typealias Result = MoviesSearchLoader.Result
    
    func searchMovies(searchText: String, completion: @escaping (Result) -> Void) {
        
        client.getSearchedMovies(searchText: searchText,inputMovies: inputMovies) { [weak self] result in
            guard self != nil else { return }
            switch result{
            case let .success(items):
                completion(.success(items))
            case let .failure(error):
                completion(.failure(error))
            
            }
            
        }        
        
    }
    
    
}
