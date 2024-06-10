# DiagnalApp

## Applied the following methodologies/Principles:
    1. TDD (Test Driven Development)
    2. Modular Design
    2. SOLID Principles
    3. Clean Architecture
    4. Dependency Injection
    5. Composition Root
    6. MVVM Architecture
    7. Decoupled UI,Business Logic, Data Access layers
    8. Designed for Scalability in mind  
    9. Seamless Pagination 

## Project Info 
•  project directory consists of (DiagnalApp.xcodeproj, DiagnalApp, DiagnalAppTests, DiagnalApp.xctestplan)

•  DiagnalApp folder contains the implementation source code files and DiagnalAppTests contains the UnitTests

•  DiagnalApp.xcodeproj have the implementation of "MoviesFeed, MoviesSearch" features.Each feature consists of UI(Views, ViewControllers, ViewModels) and domain modules

•  "MoviesFeed, MoviesSearch" features are developed in such a way that , "Modular Design" in mind. so we can able to create the modules/frameworks from it and able to reuse it across cross platform (iOS,macOS,iPadOS,watchOS)

•  "MoviesFeed, MoviesSearch" feature modules are composed in Main module by applying "Composition Root" 

•  "MoviesFeed" fetch from Remote testcases are covered in UnitTests

•  handled the Error cases 

•  fully written in Swift and UIKit

•  supported platforms: iOS 17.4 , tested with iPhone Simulator : iPhone 15 Pro 
 
## Features Info 
•  DiagnalApp contains mainly 2 Feature modules 1)MoviesFeed 2)MoviesSearch.

MoviesFeed: (show the fetched Movies from the feed)

•  fetch the MoviesFeed in a Seamless Pagination way to load from the JSON and showing the MoviesCard in a UICollectionView. if user try to scroll to the end of the last item then it will detect and start to fetch the nextPage "MoviesFeed".

•  handled the Very Long Title String with running Text animation.

•  locally cached the fetched "MoviesFeed" in MoviesFeedViewModel, so that we can use it from the cache if the feed is available in cache

MoviesSearch: (show the filtered Movies)

•  navigate to MoviesSearchViewController to do the MoviesSearch

•  get the input searchText from the user and filter the existing cached "MoviesFeed" and show the results in the UICollectionView

Thank you for Reviewing my DiagnalApp project. if you have any questions/queries, feel free to reach me




