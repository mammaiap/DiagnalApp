//
//  MoviesFeedViewModel.swift
//  DiagnalApp
//
//  Created by Muthulingam on 09/06/24.
//

import Foundation

final class MoviesFeedViewModel{
    
    typealias Observer<T> = (T) -> Void
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<MoviesFeed>?
    var onErrorStateChange: Observer<String?>?
    
    
    private var pageNum: Int = 1
    
    var hasMoreData: Bool = true
    
    var feedViewtitle: String = Localized.MoviesFeed.viewTitle
    
    var cacheFeeds: [Int: MoviesFeed] = [ : ]
    
    private let feedLoader: MoviesFeedLoader

    init(feedLoader: MoviesFeedLoader) {
        self.feedLoader = feedLoader
    }
    
}



extension MoviesFeedViewModel{
    
    func loadFeed(page: Int = 1) {
        if(self.hasMoreData){
            self.pageNum = page
            if let cacheFeed = cacheFeeds[page] {
                self.onFeedLoad?(cacheFeed)
                self.onLoadingStateChange?(false)
                return
            }
            onErrorStateChange?(.none)
            onLoadingStateChange?(true)
            
            feedLoader.load(.init(page: page)) { [weak self] result in
                guard let self = self else { return }
                if let feed = try? result.get() {
                    self.feedViewtitle = feed.title
                    self.hasMoreData = feed.pageSize >= 20
                    cacheFeeds[page] = feed
                    self.onFeedLoad?(feed)
                } else {
                    self.onErrorStateChange?(Localized.MoviesFeed.loadError)
                }
                self.onLoadingStateChange?(false)
            }
        }/*else{
            self.onLoadingStateChange?(false)
        }*/
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
    
    var isFirstPage: Bool{
        if pageNum == 1{
            return true
        }else{
            return false
        }
    }
    
    var nextPage: Int?{
        if hasMoreData{
            return pageNum + 1
        }else{
            return nil
        }
    }
    
  
}



