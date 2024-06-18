//
//  MoviesFilterLoaderTests.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 17/06/24.
//

import XCTest
@testable import DiagnalApp

final class MoviesFilterLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromClient() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedSearchTexts.isEmpty)
    }
    
    func test_searchText_on_ClientInputText(){
        let items = makeMoviesCardItems()
        let (sut, client) = makeSUT(allmovieCards: items)
        let searchText = "Family Pot"
        sut.searchMovies(searchText: searchText) { _ in }
        XCTAssertEqual(client.requestedSearchTexts, [searchText])
        
    }
    
    func test_moreInputSearchText_on_ClientMoreInputText(){
        let items = makeMoviesCardItems()
        let (sut, client) = makeSUT(allmovieCards: items)
        
        let searchText1 = "Family Pot"
        sut.searchMovies(searchText: searchText1) { _ in }
        
        let searchText2 = "The Birds"
        sut.searchMovies(searchText: searchText2) { _ in }
        
        XCTAssertEqual(client.requestedSearchTexts, [searchText1, searchText2])
    }
    
    func test_search_delivers_movies_card_on_success_response_with_items() {
        let items = makeMoviesCardItems()
        let (sut, client) = makeSUT(allmovieCards: items)
        
        let item1 = makeMoviesCard(name: "Family Pot",imagePath: "poster3.jpg")
        let item2 = makeMoviesCard(name: "Family Pot",imagePath: "poster4.jpg")
        let item3 = makeMoviesCard(name: "Family Pot",imagePath: "poster6.jpg")
        
        let filteredItems = [item1,item2,item3]
      
        let searchText = "Family Pot"
        expect(sut, searchText, toCompleteWith: .success(filteredItems), when: {
          client.complete(withSuccess: filteredItems)
      })
    }
    
    /*func test_load_deliversErrorOnClientError() {
        let items = makeMoviesCardItems()
        let (sut, client) = makeSUT(allmovieCards: items)
        let searchText = "Unkown Movie"
        
        expect(sut,searchText,toCompleteWith: failure(.searchNotFoundError)) {
            let clientError = NSError(domain: "searchNotFoundError", code: 0)
            client.complete(withFailure: clientError)
        }
        
    }*/
    

}

extension MoviesFilterLoaderTests{
    func makeSUT(allmovieCards: [MoviesCard] = [], file: StaticString = #file, line: UInt = #line) -> (MoviesFilterLoader, MoviesSearchLoaderClientSpy) {
        let client = MoviesSearchLoaderClientSpy()
        let sut = MoviesFilterLoader(inputMovies: allmovieCards, client: client)

        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

       return (sut, client)
    }
    
    private func failure(_ error: MoviesFilterLoader.Error) -> MoviesFilterLoader.Result {
        return .failure(error)
        
    }
    
    private func expect(_ sut: MoviesFilterLoader,_ searchText: String, toCompleteWith expectedResult: MoviesFilterLoader.Result, when action: ()-> Void, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
       
        sut.searchMovies(searchText:searchText){receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as MoviesFilterLoader.Error), .failure(expectedError as MoviesFilterLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file, line: line)
            }
            
            exp.fulfill()
            
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeMoviesCard(name: String? = nil, imagePath: String? = nil) -> MoviesCard {
      return MoviesCard(name: name ?? "",posterImage: imagePath ?? "")
    }
    
    func makeMoviesCardItems() -> [MoviesCard]{
        let item1 = makeMoviesCard(name: "The Birds",imagePath: "poster1.jpg")
        let item2 = makeMoviesCard(name: "Rear Window",imagePath: "poster2.jpg")
        let item3 = makeMoviesCard(name: "Family Pot",imagePath: "poster3.jpg")
        let item4 = makeMoviesCard(name: "Family Pot",imagePath: "poster4.jpg")
        let item5 = makeMoviesCard(name: "The Birds",imagePath: "poster5.jpg")
        let item6 = makeMoviesCard(name: "Family Pot",imagePath: "poster6.jpg")
       
        let items = [item1, item2, item3, item4, item5, item6]
        return items
    }
    
    func makeFamilyMoviesCardItems() -> [MoviesCard]{
        
        let item1 = makeMoviesCard(name: "Family Pot",imagePath: "poster3.jpg")
        let item2 = makeMoviesCard(name: "Family Pot",imagePath: "poster4.jpg")
        let item3 = makeMoviesCard(name: "Family Pot",imagePath: "poster6.jpg")
       
        let items = [item1, item2, item3]
        return items
    }
}

class MoviesSearchLoaderClientSpy: MoviesSearchLoaderClient {    
    
    private var messages = [(searchText: String, inputMovies: [MoviesCard], completion: (MoviesSearchLoaderClient.Result) -> Void)]()
    
    var requestedSearchTexts: [String] {
        return messages.map { $0.searchText }
    }
    
    var requestedInputMovies: [[MoviesCard]] {
        return messages.map { $0.inputMovies }
    }
    
    func getSearchedMovies(searchText: String, inputMovies: [MoviesCard], completion: @escaping (MoviesSearchLoaderClient.Result) -> Void) {
        messages.append((searchText,inputMovies,completion))
    }
    
    func complete(withFailure error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withSuccess filtered: [MoviesCard], at index: Int = 0) {
        messages[index].completion(.success(filtered))
    }
}
