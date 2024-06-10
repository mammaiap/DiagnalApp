//
//  RemoteMockedMoviesFeedLoader.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

class RemoteMockedMoviesFeedLoader: MoviesFeedLoader {
    private let baseFileName: String
    private let client: FileLoaderClient
    
    init(baseFileName: String, client: FileLoaderClient) {
        self.baseFileName = baseFileName
        self.client = client
    }
    
    typealias Result = MoviesFeedLoader.Result
    func load(_ req: PagedMoviesRequest, completion: @escaping (Result) -> Void) {
        
    }
    
    
    
}
