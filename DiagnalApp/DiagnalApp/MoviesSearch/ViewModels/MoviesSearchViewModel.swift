//
//  MoviesSearchViewModel.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

final class MoviesSearchViewModel{
    
    typealias Observer<T> = (T) -> Void
    
    var onErrorStateChange: Observer<String?>?
    var onSearchLoad: Observer<[MoviesCard]>?
    
    private let allMovies: [MoviesCard]
    
    init(allMovies: [MoviesCard]) {
        self.allMovies = allMovies
    }
    
    
}

extension MoviesSearchViewModel{
   
    func searchMovies(_ searchText: String){
      
        onErrorStateChange?(.none)
        
        if searchText.count >= 2 {
            let filteredMovies = allMovies.filter( {$0.name.localizedCaseInsensitiveContains(searchText)})
            
            if !(filteredMovies.isEmpty) {
                self.onSearchLoad?(filteredMovies)
                
            }else {
                self.onErrorStateChange?(Localized.MoviesFeed.searchNotFoundError)
            }
            
        }
        
        
    }
    
}
