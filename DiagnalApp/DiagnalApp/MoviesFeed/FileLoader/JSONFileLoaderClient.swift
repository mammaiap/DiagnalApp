//
//  JSONFileLoaderClient.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

class JSONFileLoaderClient: FileLoaderClient {
    
    enum Error: Swift.Error{
        case fileNotFoundError
        case fileLoadError
    }
    
    func get(_ fileName: String, completion: @escaping (FileLoaderClient.Result) -> Void) {
        completion(Result {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json"){
                if let data = try? Data(contentsOf: url) {
                    return (data)
                }else{
                    throw Error.fileLoadError
                }
                
            }else{
                throw Error.fileNotFoundError
            }
                
        })
        
    }
    
    
}
