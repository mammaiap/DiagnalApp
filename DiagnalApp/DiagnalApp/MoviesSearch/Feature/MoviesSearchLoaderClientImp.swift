//
//  MoviesSearchLoaderClientImp.swift
//  DiagnalApp
//
//  Created by Muthulingam on 17/06/24.
//

import Foundation

class MoviesSearchLoaderClientImp: MoviesSearchLoaderClient{   
    
    func getSearchedMovies(searchText: String, inputMovies: [MoviesCard], completion: @escaping (MoviesSearchLoaderClient.Result) -> Void) {
        
        completion(Result{
            let filteredMovies = inputMovies.filter( {$0.name.localizedCaseInsensitiveContains(searchText)})
            
            if !(filteredMovies.isEmpty) {
                return filteredMovies
                
            }else{
                throw MoviesFilterLoader.Error.searchNotFoundError
            }
            
        })

        
    }
    
    
    
}
