//
//  FileLoaderClientSpy.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
@testable import DiagnalApp

class FileLoaderClientSpy: FileLoaderClient {
    
    private var messages = [(fileName: String, completion: (FileLoaderClient.Result) -> Void)]()
    
    var requestedFileNames: [String] {
        return messages.map { $0.fileName }
    }
    
    func get(_ fileName: String, completion: @escaping (FileLoaderClient.Result) -> Void) {
        messages.append((fileName,completion))
    }
    
    
}
