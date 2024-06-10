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
    
    enum Error: Swift.Error{
        case invalidDataError
        case parseError
    }
    
    typealias Result = MoviesFeedLoader.Result
    
    func load(_ req: PagedMoviesRequest, completion: @escaping (Result) -> Void) {
        let fullFileName = getFullFileName(baseName: baseFileName, req: req)
        client.get(fullFileName) { [weak self] result in
            guard self != nil else { return }            
            switch result{
            case let .success(data):
                completion(RemoteMockedMoviesFeedLoader.map(data))
            case .failure:
                completion(.failure(Error.invalidDataError))
            
            }
        }
    }
    
    
    
}

extension RemoteMockedMoviesFeedLoader{
    private func getFullFileName(baseName: String ,req: PagedMoviesRequest) -> String {
        return baseName + "\(req.page)"
    }
    
    private static func map(_ data: Data) -> Result {
        do{
            let feed = try MoviesFeedMapper.map(data)
            return (.success(feed))
        }catch{
            return(.failure(error))
        }
        
    }
}
