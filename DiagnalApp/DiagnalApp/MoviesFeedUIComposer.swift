//
//  MoviesFeedUIComposer.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

final class MoviesFeedUIComposer{
    private init() {}
    
    public static func moviesFeedComposedWith(feedLoader: MoviesFeedLoader) -> MoviesFeedViewController {
        let feedViewModel = MoviesFeedViewModel(
            feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let feedViewController = MoviesFeedViewController.makeWith(
            viewModel: feedViewModel)
        
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(
        forwardingTo: feedViewController)        
        
        return feedViewController
    }
    
    private static func adaptFeedToCellControllers(forwardingTo controller: MoviesFeedViewController) -> (MoviesFeed) -> Void {
        return { [weak controller] feed in
            let newItems = feed.items.map { model in
                MoviesCellController(viewModel: MoviesCellViewModel(model: model))
            }
            controller?.displayNewlyFetchedItems(newItems)
        }
    }
}

private extension MoviesFeedViewController {
    static func makeWith(viewModel: MoviesFeedViewModel) -> MoviesFeedViewController {
        let bundle = Bundle(for: MoviesFeedViewController.self)
        let storyboard = UIStoryboard(name: "MoviesFeed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController{ coder in
            MoviesFeedViewController(viewModel: viewModel, coder: coder)
        }!
        
        return feedController
    }
}
