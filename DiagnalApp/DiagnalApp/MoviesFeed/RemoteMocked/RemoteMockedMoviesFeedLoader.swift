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
        let fullFileName = getFullFileName(baseName: baseFileName, req: req)
        client.get(fullFileName) { _ in
            
        }
    }
    
    
    
}

extension RemoteMockedMoviesFeedLoader{
    func getFullFileName(baseName: String ,req: PagedMoviesRequest) -> String {
        return baseName + "\(req.page)"
    }
}
