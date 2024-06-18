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
    
    private let searchLoader: MoviesSearchLoader
    
    init(searchLoader: MoviesSearchLoader){
        self.searchLoader = searchLoader
    }
       
}

extension MoviesSearchViewModel{
    
    func searchMovies(_ searchText: String){
        
        onErrorStateChange?(.none)
        
        searchLoader.searchMovies(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            
            if let filtered = try? result.get(){
                
                self.onSearchLoad?(filtered)
                
            }else{
                self.onErrorStateChange?(Localized.MoviesFeed.searchNotFoundError)
            }
            
        }
        
    }
   
   
    
}
