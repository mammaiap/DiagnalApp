//
//  MoviesSearchUIComposer.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

final class MoviesSearchUIComposer{
    private init() {}
    
    public static func moviesSearchComposedWith(allmovieCards: [MoviesCard]) -> MoviesSearchViewController {
        
        let searchViewModel = MoviesSearchViewModel(allMovies: allmovieCards)
        
        let searchViewController = MoviesSearchViewController.makeWith(viewModel: searchViewModel)
        
        
        searchViewModel.onSearchLoad = adaptSearchMoviesToCellControllers(forwardingTo: searchViewController)
        
        return searchViewController
    }
    
    private static func adaptSearchMoviesToCellControllers(forwardingTo controller: MoviesSearchViewController) -> ([MoviesCard]) -> Void {
        return { [weak controller] items in
            let newItems = items.map { model in
                MoviesCellController(id: model,viewModel: MoviesCellViewModel(model: model))
            }
            controller?.set(newItems)
        }
    }
    
}

private extension MoviesSearchViewController {
    static func makeWith(viewModel: MoviesSearchViewModel) -> MoviesSearchViewController {
        let bundle = Bundle(for: MoviesSearchViewController.self)
        let storyboard = UIStoryboard(name: "MoviesSearch", bundle: bundle)
        let searchController = storyboard.instantiateInitialViewController{ coder in
            MoviesSearchViewController(viewModel: viewModel, coder: coder)
        }!
       
        return searchController
    }
}
