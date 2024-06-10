//
//  LoadMoviesFeedFromRemoteMockedUseCaseTests.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 10/06/24.
//

import XCTest
@testable import DiagnalApp

final class LoadMoviesFeedFromRemoteMockedUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRemoteMockedLoader() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedFileNames.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(baseFile: String = "", file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMockedMoviesFeedLoader,client: FileLoaderClientSpy) {
        let client = FileLoaderClientSpy()
        let sut = RemoteMockedMoviesFeedLoader(baseFileName: baseFile, client: client)
        trackMemoryLeaks(sut,file: file,line: line)
        trackMemoryLeaks(client,file: file,line: line)
        return (sut,client)
        
    }

}
