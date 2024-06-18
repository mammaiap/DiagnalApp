//
//  MoviesSearchViewControllerTests.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 17/06/24.
//

import XCTest
@testable import DiagnalApp

final class MoviesSearchViewControllerTests: XCTestCase {
    
    func test_searchText_on_init(){
        let (_, loader) = makeSUT()
        XCTAssertTrue(loader.requestedSearchTexts.isEmpty)
    }
    
    func test_searchText_on_InputText(){
        let items = makeMoviesCardItems()
        let (sut, loader) = makeSUT(allmovieCards: items)
        let searchText = "Family Pot"
        sut.searchMovies(searchText)        
        XCTAssertEqual(loader.requestedSearchTexts, [searchText])
        
    }
    
    func test_searchText_on_More_InputText(){
        let items = makeMoviesCardItems()
        let (sut, loader) = makeSUT(allmovieCards: items)
        
        let searchText1 = "Family Pot"
        sut.searchMovies(searchText1)
        
        let searchText2 = "The Birds"
        sut.searchMovies(searchText2)
        
        XCTAssertEqual(loader.requestedSearchTexts, [searchText1, searchText2])        
    }
    
    func test_loads_filtered_movies_count_equals_to_numberofitems_in_collectionview() {
        let items = makeMoviesCardItems()
        let (sut, loader) = makeSUT(allmovieCards: items)
        sut.simulateAppearance()
        
        let searchText1 = "Family Pot"
        let filteredItems = makeFamilyMoviesCardItems()
          
        sut.searchMovies(searchText1)
          
        loader.complete(withSuccess: filteredItems)
        
        XCTAssertEqual(sut.numberOfItems, filteredItems.count)
        
    }

    func test_loads_filtered_movies_get_displayed_in_collectionview() {
      
      let item1 = makeMoviesCard(name: "Family Pot",imagePath: "poster3.jpg")
      let item2 = makeMoviesCard(name: "Family Pot",imagePath: "poster4.jpg")
      let item3 = makeMoviesCard(name: "Family Pot",imagePath: "poster6.jpg")
     
      let items = makeMoviesCardItems()
        
      let (sut, loader) = makeSUT(allmovieCards: items)
      sut.simulateAppearance()
        
      let searchText1 = "Family Pot"
      let filteredItems = [item1,item2,item3]
        
      sut.searchMovies(searchText1)
        
      loader.complete(withSuccess: filteredItems)
        
      let viewZero = sut.simulateItemVisible(at: 0) as? MovieCell
      XCTAssertEqual(viewZero?.lblMovieName.text,item1.name)

      let viewOne = sut.simulateItemVisible(at: 1) as? MovieCell
      XCTAssertEqual(viewOne?.lblMovieName.text,item2.name)
        
      let viewTwo = sut.simulateItemVisible(at: 2) as? MovieCell
      XCTAssertEqual(viewTwo?.lblMovieName.text,item3.name)
        
    }
    
    func test_loads_noitems_on_searchError() {
        let items = makeMoviesCardItems()
          
        let (sut, loader) = makeSUT(allmovieCards: items)
        sut.simulateAppearance()
          
        let searchText1 = "Unkown Movie"
        sut.searchMovies(searchText1)
        
        let searchError = NSError(domain: "Test", code: 0)
        loader.complete(withFailure: searchError)
        
        XCTAssertEqual(sut.numberOfItems, 0)
        
    }

    
}

extension MoviesSearchViewControllerTests{    
    
    func makeSUT(allmovieCards: [MoviesCard] = [], file: StaticString = #file, line: UInt = #line) -> (MoviesSearchViewController, MoviesSearchLoaderSpy) {
        let loader = MoviesSearchLoaderSpy(inputMovies: allmovieCards)
        let sut = MoviesSearchUIComposer.moviesSearchComposedWith(searchLoader: loader)

        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

       return (sut, loader)
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

class MoviesSearchLoaderSpy: MoviesSearchLoader {
    
    let inputMovies: [MoviesCard]
    
    init(inputMovies: [MoviesCard]) {
        self.inputMovies = inputMovies
    }
    
    private var messages = [(searchText: String, completion: (MoviesSearchLoader.Result) -> Void)]()
    
    var requestedSearchTexts: [String] {
        return messages.map { $0.searchText }
    }
    
    func searchMovies(searchText: String, completion: @escaping (MoviesSearchLoader.Result) -> Void) {
        messages.append((searchText,completion))
    }
    
    func complete(withFailure error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withSuccess filtered: [MoviesCard], at index: Int = 0) {
        messages[index].completion(.success(filtered))
    }
    
    
}


