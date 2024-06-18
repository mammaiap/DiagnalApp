//
//  MoviesFeedViewControllerTests.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 16/06/24.
//

import XCTest
@testable import DiagnalApp

final class MoviesFeedViewControllerTests: XCTestCase {

    func test_on_init_sets_title() {
        let (sut, _) = makeSUT()
        sut.simulateAppearance()
        XCTAssertEqual(sut.title, "Romantic Comedy")
    }
    
    func test_refreshControl(){
        let (sut, _) = makeSUT()
        sut.simulateAppearance()
        XCTAssertEqual(sut.cvMovieListing.refreshControl?.isRefreshing, true)
          
        sut.cvMovieListing.refreshControl?.endRefreshing()
        sut.cvMovieListing.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual(sut.cvMovieListing.refreshControl?.isRefreshing, true)
        
        sut.cvMovieListing.refreshControl?.endRefreshing()
        sut.simulateAppearance()
        XCTAssertEqual(sut.cvMovieListing.refreshControl?.isRefreshing, false)
    }
    
    func test_load_actions_request_moviesfeed_from_loader() {
      
        let (sut, loader) = makeSUT()
        XCTAssertTrue(loader.messages.isEmpty)
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.messages, [.load(PagedMoviesRequest(page: 1))])
        
        sut.cvMovieListing.refreshControl?.sendActions(for: .valueChanged)
       
        XCTAssertEqual(loader.messages, [
          .load(PagedMoviesRequest(page: 1)),
          .load(PagedMoviesRequest(page: 1))
        ])
     
    }    
    
    func test_load_completion_renders_successfully_loaded_movies_feed() {
      let (sut, loader) = makeSUT()
      let items = Array(0..<9).map { index in makeMoviesCard(name: "name1",imagePath: "imagepath.jpg") }
      let page = makeMoviesFeed(items: items, title: "title1")

      sut.simulateAppearance()
      assertThat(sut, isRendering: [])

      loader.loadFeedCompletes(with: .success(page))
      assertThat(sut, isRendering: items)
    }
    
    func test_movies_feed_card_loads_movietitle_when_visible() {
      let (sut, loader) = makeSUT()
      let itemZero = makeMoviesCard(name: "name0",imagePath: "imagepath0.jpg")
      let itemOne = makeMoviesCard(name: "name1",imagePath: "imagepath1.jpg")
      let feedPage = makeMoviesFeed(items:[itemZero, itemOne])
      

      sut.simulateAppearance()
      loader.loadFeedCompletes(with: .success(feedPage))
     

      let viewZero = sut.simulateItemVisible(at: 0) as? MovieCell
        XCTAssertEqual(viewZero?.lblMovieName.text,itemZero.name)

      let viewOne = sut.simulateItemVisible(at: 1) as? MovieCell
        XCTAssertEqual(viewOne?.lblMovieName.text,itemOne.name)
    }
    
    func test_movies_feed_card_loads_verylongmovietitle_truncated() {
        let (sut, loader) = makeSUT()
        let itemZero = makeMoviesCard(name: "The Birds with an Extra Long Title",imagePath: "imagepath0.jpg")
       
        let feedPage = makeMoviesFeed(items:[itemZero])

        sut.simulateAppearance()
        loader.loadFeedCompletes(with: .success(feedPage))

        let viewZero = sut.simulateItemVisible(at: 0) as? MovieCell
        XCTAssertTrue(((viewZero?.lblMovieName?.isTruncated) != nil))
      
    }
    
    func test_moviesfeed_loader_completes_from_background_to_main_thread() {
      let (sut, loader) = makeSUT()
      let item = makeMoviesCard(name: "name0",imagePath: "imagepath0.jpg")
      let feedPage = makeMoviesFeed(items:[item])
        sut.simulateAppearance()

      let exp = expectation(description: "await background queue")
      DispatchQueue.global().async {
        loader.loadFeedCompletes(with: .success(feedPage))
        exp.fulfill()
      }
      wait(for: [exp], timeout: 1.0)
    }
    
    func test_on_scroll_to_buttom_requests_next_page() {
      let (sut, loader) = makeSUT()
      let items = Array(0..<20).map { index in makeMoviesCard(name: "name1",imagePath: "imagepath1.jpg")  }
      let feedPage = makeMoviesFeed(items: items, title: "title1", totalItems: 54, pageNumber: 1, pageSize: 20)

      sut.simulateAppearance()
      loader.loadFeedCompletes(with: .success(feedPage))

      sut.simulatePagingRequest()
      XCTAssertEqual(loader.messages, [
        .load(PagedMoviesRequest(page: 1)),
        .load(PagedMoviesRequest(page: 2))
      ])
    }
    
    func test_on_scroll_to_buttom_does_not_request_if_on_last_page() {
      let (sut, loader) = makeSUT()
      let items = Array(0..<5).map { index in makeMoviesCard(name: "name1",imagePath: "imagepath1.jpg") }
      let feedPage = makeMoviesFeed(items: items, title: "title1", totalItems: 54, pageNumber: 1, pageSize: 14)

      sut.simulateAppearance()
      loader.loadFeedCompletes(with: .success(feedPage))

      sut.simulatePagingRequest()
      XCTAssertEqual(loader.messages, [
        .load(PagedMoviesRequest(page: 1))
      ])
    }
    
    func test_onUserRefresh_afterPagingRequest_doesNotRequestsFirstPageAgain() {
      let (sut, loader) = makeSUT()
      let items = Array(0..<20).map { index in makeMoviesCard(name: "name1",imagePath: "imagepath1.jpg") }
      let feedPage = makeMoviesFeed(items: items, title: "title1", totalItems: 54, pageNumber: 1, pageSize: 20)

      sut.simulateAppearance()
      loader.loadFeedCompletes(with: .success(feedPage))

      sut.simulatePagingRequest()
      sut.simulateUserRefresh()

      XCTAssertEqual(loader.messages, [
        .load(PagedMoviesRequest(page: 1)),
        .load(PagedMoviesRequest(page: 2))
      ])
    }
    
    func test_onUserRefresh_afterPagingRequest_appendsNextPage() {
      let (sut, loader) = makeSUT()
      
      let items1 = (0..<20).map { index in makeMoviesCard(name: "name1",imagePath: "imagepath1.jpg") }
      let feedPage1 = makeMoviesFeed(items: items1, title: "title1", totalItems: 54, pageNumber: 1, pageSize: 20)

      let items2 = (0..<20).map { index in makeMoviesCard(name: "name2",imagePath: "imagepath2.jpg")}
      let feedPage2 = makeMoviesFeed(items: items2, title: "title2", totalItems: 54, pageNumber: 2, pageSize: 20)
        
      let items3 = (0..<14).map { index in makeMoviesCard(name: "name3",imagePath: "imagepath3.jpg")}
      let feedPage3 = makeMoviesFeed(items: items3, title: "title3", totalItems: 54, pageNumber: 3, pageSize: 14)

      sut.simulateAppearance()
      assertThat(sut, isRendering: [])

      loader.loadFeedCompletes(with: .success(feedPage1))
      assertThat(sut, isRendering: items1)
      
      sut.simulatePagingRequest()
      loader.loadFeedCompletes(with: .success(feedPage2))
      assertThat(sut, isRendering: items1 + items2)
        
      sut.simulatePagingRequest()
      loader.loadFeedCompletes(with: .success(feedPage3))
      assertThat(sut, isRendering: items1 + items2 + items3)
    }
    
    func test_onSearchButtonTap_notifiesHandler() {
        
        let items = Array(0..<20).map { index in makeMoviesCard(name: "name1",imagePath: "imagepath1.jpg") }
        let feedPage = makeMoviesFeed(items: items, title: "title1", totalItems: 54, pageNumber: 1, pageSize: 20)

        var selectedImages = [MoviesCard]()
        
        let (sut, loader) = makeSUT(onSearchSpy: { selectedImages.append(contentsOf: $0) })
        
        sut.simulateAppearance()
        loader.loadFeedCompletes(with: .success(feedPage))
        
        sut.simulateOnSeachButtonTap()
        XCTAssertEqual(selectedImages, items)
        
    }
    
}

extension MoviesFeedViewControllerTests{
    
    func makeSUT(onSearchSpy: @escaping ([MoviesCard]) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> (MoviesFeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = MoviesFeedUIComposer.moviesFeedComposedWith(feedLoader: loader, onSearch: onSearchSpy)

        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)

       return (sut, loader)
    }
    
    func makeError(_ str: String = "uh oh, something went wrong") -> NSError {
      return NSError(domain: "TEST_ERROR", code: -1, userInfo: [NSLocalizedDescriptionKey: str])
    }
    
    func makeMoviesCard(name: String? = nil, imagePath: String? = nil) -> MoviesCard {
      return MoviesCard(name: name ?? "",posterImage: imagePath ?? "")
    }
    
    func makeMoviesFeed(items: [MoviesCard] = [],title: String = "", totalItems: Int = 1, pageNumber: Int = 1, pageSize: Int = 1) -> MoviesFeed {
        
        return MoviesFeed(title: title,totalContentItems: totalItems,pageNum: pageNumber,pageSize: pageSize,items: items)
        
    }
    
    func assertThat(_ sut: MoviesFeedViewController, isRendering feed: [MoviesCard], file: StaticString = #file, line: UInt = #line) {
      guard sut.numberOfItems == feed.count else {
        return XCTFail("Expected \(feed.count) cards, got \(sut.numberOfItems) instead.", file: file, line: line)
      }
      feed.indices.forEach { index in
        assertThat(sut, hasViewConfiguredFor: feed[index], at: index)
      }
    }

    func assertThat(_ sut: MoviesFeedViewController, hasViewConfiguredFor item: MoviesCard, at index: Int, file: StaticString = #file, line: UInt = #line) {
      let cell = sut.itemAt(index)
      guard let _ = cell as? MovieCell else {
        return XCTFail("Expected \(MovieCell.self) instance, got \(String(describing: cell)) instead", file: file, line: line)
      }
    }
    
}


class LoaderSpy: MoviesFeedLoader {
    enum Message: Equatable{
        case load(PagedMoviesRequest)
        
        static func == (lhs: Message, rhs: Message) -> Bool {
            switch (lhs, rhs) {
                case (.load, .load):
                    return true
                
            }
        }
    }
    
    private(set) var messages: [Message] = []
    private var loadCompletions: [(MoviesFeedLoader.Result) -> Void] = []
    
    
    
    func load(_ req: PagedMoviesRequest, completion: @escaping (MoviesFeedLoader.Result) -> Void) {
        messages.append(.load(req))
        loadCompletions.append(completion)
        
    }
    
    func loadFeedCompletes(with result: MoviesFeedLoader.Result, at index: Int = 0) {
      loadCompletions[index](result)
    }
}
