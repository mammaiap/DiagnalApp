//
//  MoviesFeedViewModel.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

final class MoviesFeedViewModel{
    
    typealias Observer<T> = (T) -> Void
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<MoviesFeed>?
    var onErrorStateChange: Observer<String?>?
    
    private var currentPageNum: Int = 1
    
    private var maxPageNum: Int = 3
    
    var hasMoreData: Bool = true
    
    var feedViewtitle: String = ""
    
    var cacheFeeds: [Int: MoviesFeed] = [ : ]   
    
    private let feedLoader: MoviesFeedLoader

    init(feedLoader: MoviesFeedLoader) {
        self.feedLoader = feedLoader
    }
    
}

extension MoviesFeedViewModel{
    var allMovieCards: [MoviesCard]{
        let moviesFeed = Array(cacheFeeds.values)
        var allMovies = [MoviesCard]()
        
        for feed in moviesFeed {
            allMovies.append(contentsOf: feed.items)
        }
        return allMovies
    }
}

extension MoviesFeedViewModel{
    
    func loadFeed() {
        if(self.currentPageNum <= maxPageNum){
            if let cacheFeed = cacheFeeds[self.currentPageNum] {
                self.onFeedLoad?(cacheFeed)
                if self.hasMoreData {
                    self.currentPageNum += 1
                }
                self.onLoadingStateChange?(false)
                
            }
            onErrorStateChange?(.none)
            onLoadingStateChange?(true)
            
            feedLoader.load(.init(page: currentPageNum)) { [weak self] result in
                guard let self = self else { return }
                if let feed = try? result.get() {                                   
                    self.feedViewtitle = feed.title
                    self.hasMoreData = feed.pageSize >= 20
                    if self.hasMoreData {
                        self.currentPageNum += 1
                    }
                    cacheFeeds[self.currentPageNum] = feed
                    self.onFeedLoad?(feed)
                    
                } else {
                    self.onErrorStateChange?(Localized.MoviesFeed.loadError)
                }
                self.onLoadingStateChange?(false)
            }
        }
    }
}
