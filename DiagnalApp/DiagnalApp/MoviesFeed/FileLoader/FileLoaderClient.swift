//
//  FileLoaderClient.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

protocol FileLoaderClient {
    typealias Result = Swift.Result<Data, Error>
    func get(_ fileName: String, completion: @escaping (Result) -> Void)
    
}
