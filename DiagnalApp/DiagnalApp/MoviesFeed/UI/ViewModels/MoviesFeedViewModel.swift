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
    
    var hasMoreData: Bool = true
    
    var feedViewtitle: String = ""
    
    var cacheFeeds: [Int: MoviesFeed] = [ : ]
    
   
    
    private let feedLoader: MoviesFeedLoader

    init(feedLoader: MoviesFeedLoader) {
        self.feedLoader = feedLoader
    }
    
}



extension MoviesFeedViewModel{
    
    func loadFeed() {
        if let cacheFeed = cacheFeeds[self.currentPageNum] {
            self.onFeedLoad?(cacheFeed)
            self.currentPageNum += 1
        }
        onErrorStateChange?(.none)
        onLoadingStateChange?(true)
        
        feedLoader.load(.init(page: currentPageNum)) { [weak self] result in
            guard let self = self else { return }
            if let feed = try? result.get() {
                cacheFeeds[self.currentPageNum] = feed
                self.onFeedLoad?(feed)
                self.currentPageNum += 1
                self.hasMoreData = feed.pageSize >= 20
                self.feedViewtitle = feed.title
            } else {
                self.onErrorStateChange?(Localized.MoviesFeed.loadError)
            }
            self.onLoadingStateChange?(false)
        }
    }
}




