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
            client.complete(withFailure: clientError)
        }
        
    }
    
    func test_load_deliversErrorWithInvalidJSON() {
        
        let (sut, client) = makeSUT()
        
        expect(sut,toCompleteWith: failure(.parseError)) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withSuccess: invalidJSON)
        }
        
    }
    
    func test_load_delivers_empty_collection_on_success_response_with_no_items() {
      let (sut, client) = makeSUT()
      let emptyPage = makeMoviesFeed(items: [],title: "title1")
      let emptyPageData = makeItemsJSONData(for: emptyPage.json)
      expect(sut, toCompleteWith: .success(emptyPage.model), when: {
        client.complete(withSuccess: emptyPageData)
      })
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
    
    private func makeItemsJSONData(for items: [String: Any]) -> Data {
      let data = try! JSONSerialization.data(withJSONObject: items)
      return data
    }
    
    func makeMoviesFeed(items: [(model: MoviesCard, json: [String : Any])] = [],title: String = "", totalItems: Int = 1, pageNumber: Int = 1, pageSize: Int = 1) -> (model: MoviesFeed, json: [String: Any]) {

      let model = MoviesFeed(title: title, 
                          totalContentItems: totalItems,
                          pageNum: pageNumber,
                          pageSize: pageSize,
                          items: items.map { $0.model }
                          )
        
      
    let contentItemsDict: [String: Any] = [
          "content": items.map { $0.json }
        ]
     
    let pageDict: [String: Any] = [          
          "title": title,
          "total-content-items": "\(totalItems)",
          "page-num": "\(pageNumber)",
          "page-size": "\(pageSize)",
          "content-items": contentItemsDict
        ]
        

      let json: [String: Any] = [
        "page": pageDict        
      ]

      return (model, json.compactMapValues { $0 })
    }
    
    func makeMoviesCard(name: String? = nil, imagePath: String? = nil ) -> (model: MoviesCard, json: [String: Any]) {
        
      let model = MoviesCard(
        name: name ?? "",
        posterImage: imagePath ?? ""
      )

      let json: [String: Any] = [        
        "name": model.name,
        "poster-image": model.posterImage
      ]

      return (model, json)
    }
    
    private func makePagedMoviesRequest(pagedNum: Int = 1) -> PagedMoviesRequest {
        return PagedMoviesRequest(page: pagedNum)
    }
    
    private func getBaseFileName() -> String {
        return "CONTENTLISTINGPAGE-PAGE"
    }

}
