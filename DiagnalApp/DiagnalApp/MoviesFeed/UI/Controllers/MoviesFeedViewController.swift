//
//  MoviesFeedViewController.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

class MoviesFeedViewController: UIViewController {
    
    @IBOutlet private(set) var cvMovieListing: UICollectionView!
    @IBOutlet private(set) var lblTitle: UILabel!
    @IBOutlet private(set) var btnBack: UIButton!
    @IBOutlet private(set) var btnSearch: UIButton!
    @IBOutlet private(set) var txtSearch: UISearchBar!
    @IBOutlet weak var vwLoading: UIView!
   
    
    private var isViewAppeared: Bool = false
    private var isLoadingMore: Bool = false
    private var isSearching: Bool = false
    
    private var viewModel: MoviesFeedViewModel
    
    
    init?(viewModel: MoviesFeedViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    @available(*, unavailable, renamed: "init(product:coder:)")
    required init?(coder: NSCoder) {
        fatalError("Invalid way of decoding this class")
    }
    
    var collectionModel = [MoviesCellController]()
   
    
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
        // This will reset flow layout and reload collection view
        cvMovieListing.collectionViewLayout.invalidateLayout()
        cvMovieListing.reloadData()
    }
    
    private func refresh() {
        viewModel.loadFeed()
    }
    
    private func setupUI() {
        cvMovieListing.delegate = self
        cvMovieListing.dataSource = self
        cvMovieListing.register(UINib(nibName: MovieCell.cellID, bundle: nil), forCellWithReuseIdentifier: MovieCell.cellID)
        txtSearch.delegate = self
        
        cvMovieListing.refreshControl = UIRefreshControl()
        txtSearch.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        hideSpinnerView()
    }
    
    //MARK: - Actions
    @IBAction func btnBackTap(_ sender: UIButton) {
        
        
    }
    
    @IBAction func btnSearchTap(_ sender: UIButton) {
        /*
        if sender.isSelected {
            isSearching = false
            searching(isStart: false) // Searching stops
        } else {
            searching(isStart: true) // Searching starts
        }*/
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

extension MoviesFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        return cellController(forRowAt: indexPath).view(in: collectionView, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).preload()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
}

extension MoviesFeedViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
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
          if(!isLoadingMore && viewModel.hasMoreData){
              isLoadingMore = true
              self.fetchMoreItemsToDisplay()
          }
      }
    }
}

private extension MoviesFeedViewController{
    private func cellController(forRowAt indexPath: IndexPath) -> MoviesCellController {
        return collectionModel[indexPath.row]
        
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
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
        if isSearching{
            self.displaySearchedItems(newItems)
        }else{
            if(collectionModel.isEmpty){
                self.appendItems(newItems)
            }else{
                self.insertItems(newItems)
            }
        }
    }
}

private extension MoviesFeedViewController{
    private func fetchMoreItemsToDisplay(){
        showSpinnerView()
        refresh()
    }
    
    private func showSpinnerView(){
        vwLoading.isHidden = false
       
    }
    
    private func hideSpinnerView(){
        vwLoading.isHidden = true
    }
    
    private func displaySearchedItems(_ newItems: [MoviesCellController]){
        collectionModel.removeAll()
        collectionModel.append(contentsOf: newItems)
        cvMovieListing.reloadData()
        
    }
    
    private func appendItems(_ newItems: [MoviesCellController]){
        collectionModel.append(contentsOf: newItems)
        cvMovieListing.reloadData()
        isLoadingMore = false
    }
    
    private func insertItems(_ newItems: [MoviesCellController]){
        if(!newItems.isEmpty){
            let updatedCollections = newItems
            
            var insIndices = [IndexPath]()
            
            for item in 0..<updatedCollections.count {
                let indexPath = IndexPath(row: (item + self.collectionModel.count), section: 0)
                insIndices.append(indexPath)
            }

            self.collectionModel.append(contentsOf: updatedCollections)
            
            self.cvMovieListing?.performBatchUpdates({
                if(!insIndices.isEmpty){
                    self.cvMovieListing?.insertItems(at: insIndices)
                }
            }, completion: { [weak self]  _ in
                guard let self = self else { return }
                self.hideSpinnerView()
            })
            isLoadingMore = false
        }
    }
}

private extension MoviesFeedViewController{
    func searching(isStart: Bool) {

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            self.btnBack.alpha = isStart ? 0.0 : 1.0
            self.btnBack.isHidden = isStart
            self.lblTitle.alpha = isStart ? 0.0 : 1.0
            self.lblTitle.isHidden = isStart
            self.txtSearch.isHidden = !isStart
            self.btnSearch.isSelected = isStart
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        _ = isStart ? txtSearch.becomeFirstResponder() : txtSearch.resignFirstResponder()
        isSearching ? Void() : cvMovieListing.reloadData()
        txtSearch.text = ""
       
    }
}

extension MoviesFeedViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
       /* if searchText.count >= 2 {
            isSearching = true
            viewModel.searchMovies(searchText)
        }*/
        
        
    }
}
