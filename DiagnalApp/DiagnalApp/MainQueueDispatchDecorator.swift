//
//  MainQueueDispatchDecorator.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

final class MainQueueDispatchDecorator<T>{
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else{
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: MoviesFeedLoader where T == MoviesFeedLoader {
    func load(_ req: PagedMoviesRequest,completion: @escaping (MoviesFeedLoader.Result) -> Void) {
        decoratee.load(req) {[weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
}
