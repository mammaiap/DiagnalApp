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
    
    func test_load_requestsDataFromRemoteMockedLoader() {
        
        let request = makePagedMoviesRequest(pagedNum: 1)
        
        let baseFileName = getBaseFileName()
        
        let expectedFileName = baseFileName + "\(request.page)"
        
        let (sut, client) = makeSUT(baseFile: baseFileName)
        sut.load(request) { _ in }

        XCTAssertEqual(client.requestedFileNames, [expectedFileName])
    }
    
    func test_loadTwice_requestsDataFromFileNameTwice() {
        
        let request = makePagedMoviesRequest(pagedNum: 1)
        
        let baseFileName = getBaseFileName()

        let expectedFileName = baseFileName + "\(request.page)"        
        
        let (sut, client) = makeSUT(baseFile: baseFileName)

        sut.load(request) { _ in }
        sut.load(request) { _ in }

        XCTAssertEqual(client.requestedFileNames, [expectedFileName, expectedFileName])
    }
    
    func test_load_deliversErrorOnClientError() {        
        let (sut, client) = makeSUT()
        expect(sut,toCompleteWith: failure(.invalidDataError)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(baseFile: String = "", file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMockedMoviesFeedLoader,client: FileLoaderClientSpy) {
        let client = FileLoaderClientSpy()
        let sut = RemoteMockedMoviesFeedLoader(baseFileName: baseFile, client: client)
        trackMemoryLeaks(sut,file: file,line: line)
        trackMemoryLeaks(client,file: file,line: line)
        return (sut,client)
        
    }
    
    private func failure(_ error: RemoteMockedMoviesFeedLoader.Error) -> RemoteMockedMoviesFeedLoader.Result {
        return .failure(error)
        
    }
    
    private func expect(_ sut: RemoteMockedMoviesFeedLoader, toCompleteWith expectedResult: RemoteMockedMoviesFeedLoader.Result, when action: ()-> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        let req = makePagedMoviesRequest(pagedNum: 1)
        sut.load(req){receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteMockedMoviesFeedLoader.Error), .failure(expectedError as RemoteMockedMoviesFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file, line: line)
            }
            
            exp.fulfill()
            
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makePagedMoviesRequest(pagedNum: Int = 1) -> PagedMoviesRequest {
        return PagedMoviesRequest(page: pagedNum)
    }
    
    private func getBaseFileName() -> String {
        return "CONTENTLISTINGPAGE-PAGE"
    }

}
