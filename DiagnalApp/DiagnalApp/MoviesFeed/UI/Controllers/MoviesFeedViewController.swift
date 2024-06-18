//
//  MoviesFeedViewController.swift
//  DiagnalApp
//
//  Created by Muthulingam on 09/06/24.
//

import Foundation
import UIKit

class MoviesFeedViewController: UIViewController {
    
    @IBOutlet private(set) var cvMovieListing: UICollectionView!
    @IBOutlet private(set) var lblTitle: UILabel!
    @IBOutlet private(set) var btnBack: UIButton!
    @IBOutlet private(set) var btnSearch: UIButton!
    @IBOutlet private(set) var vwLoading: UIView!
   
    
    private var isViewAppeared: Bool = false
    private var isUIReadyForLoadMore: Bool = true
    var onSearch: ([MoviesCard]) -> Void = { _ in }
    
    private var viewModel: MoviesFeedViewModel
    
    
    init?(viewModel: MoviesFeedViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    @available(*, unavailable, renamed: "init(product:coder:)")
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    func set(_ newItems: [MoviesCellController]) {
      var snapshot = NSDiffableDataSourceSnapshot<Int, MoviesCellController>()
      snapshot.appendSections([0])
      snapshot.appendItems(newItems, toSection: 0)
      dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func append(_ newItems: [MoviesCellController]) {
      var snapshot = dataSource.snapshot()
      snapshot.appendItems(newItems, toSection: 0)
      dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, MoviesCellController> = {
        .init(collectionView: cvMovieListing) { collectionView, indexPath, controller in
          controller.view(in: collectionView, for: indexPath)
        }
    }()
    
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if !isViewAppeared{
            refresh()
            isViewAppeared = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        cvMovieListing.collectionViewLayout.invalidateLayout()
        cvMovieListing.reloadData()
    }
    
    @objc private func refresh() {
        viewModel.loadFeed()
    }   
    
    private func setupUI() {
        cvMovieListing.delegate = self
        cvMovieListing.dataSource = dataSource
        cvMovieListing.register(UINib(nibName: MovieCell.cellID, bundle: nil), forCellWithReuseIdentifier: MovieCell.cellID)
        
        cvMovieListing.refreshControl = UIRefreshControl()
        cvMovieListing.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        hideSpinnerView()
    }
    
    //MARK: - Actions
    @IBAction func btnBackTap(_ sender: UIButton) {
        // pop to its ParentViewController
        
    }
    
    @IBAction func btnSearchTap(_ sender: UIButton) {
        
        let allMovies = viewModel.allMovieCards
        onSearch(allMovies)
        
    }
    
}

extension MoviesFeedViewController{
    func bind() {
        title = viewModel.feedViewtitle
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
                guard let self = self else { return }
                
                if isLoading {
                    self.cvMovieListing.refreshControl?.beginRefreshing()
                } else {
                    self.cvMovieListing.refreshControl?.endRefreshing()
                }
        }

        viewModel.onErrorStateChange = { [weak self] errorMessage in
                guard let self = self else { return }
                if let message = errorMessage {
                    self.showErrorAlert(with: message)
                }
        }
        
    }
    
    func showErrorAlert(with errorMessage: String) -> Void{
        let alert = UIAlertController(title: Localized.MoviesFeed.errorTitle, message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Localized.MoviesFeed.errorOKButtonText, style: UIAlertAction.Style.default, handler: nil))
               
        self.present(alert, animated: true, completion: nil)
        
    }
}

extension MoviesFeedViewController: UICollectionViewDelegate{
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
      guard cvMovieListing.refreshControl?.isRefreshing == true else { return }
        refresh()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.preload()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
}

extension MoviesFeedViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.preload()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
}

extension MoviesFeedViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard scrollView.isDragging else { return }
      
      let offsetY = scrollView.contentOffset.y
      let contentHeight = scrollView.contentSize.height
      if (offsetY > contentHeight - scrollView.frame.height) {
          if(viewModel.hasMoreData && self.isUIReadyForLoadMore){
              self.isUIReadyForLoadMore = false
              self.fetchMoreItemsToDisplay()
          }
      }
    }
}

private extension MoviesFeedViewController{
    private func cellController(forRowAt indexPath: IndexPath) -> MoviesCellController? {
        let controller = dataSource.itemIdentifier(for: indexPath)
        return controller
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelLoad()
    }
    
}

extension MoviesFeedViewController: UICollectionViewDelegateFlowLayout {
    
    // Size for Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width: CGFloat = 0.0
        if UIDevice.current.orientation.isLandscape { // check if the device orientation is portrait or landscape?
            width = (view.layer.frame.size.width - 112) / 6
        } else {
            width = (view.layer.frame.size.width - 64) / 3
        }
        
        let height = width + (width / 1.2)
        return CGSize(width: width, height: height)
    }
    
    // Section spacing around whole collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 40, left: 16, bottom: 26, right: 16)
    }
    
    // Spacing in between rows
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 36
    }
    
    // Spacing in between items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}

extension MoviesFeedViewController{
    func displayNewlyFetchedItems(_ newItems: [MoviesCellController]){
        
        if(viewModel.isFirstPage){
            set(newItems)
        }else{
            append(newItems)
        }
        self.hideSpinnerView()
        self.isUIReadyForLoadMore = true
    }
}

private extension MoviesFeedViewController{
    private func fetchMoreItemsToDisplay(){
        if viewModel.hasMoreData,let nextPage = viewModel.nextPage{
            showSpinnerView()
            viewModel.loadFeed(page: nextPage)
        }
        
    }
    
    private func showSpinnerView(){
        vwLoading.isHidden = false
       
    }
    
    private func hideSpinnerView(){
        vwLoading.isHidden = true
    }
   
}




