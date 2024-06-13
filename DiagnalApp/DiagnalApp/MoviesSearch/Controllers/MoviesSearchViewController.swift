//
//  MoviesSearchViewController.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

class MoviesSearchViewController: UIViewController {
    
    @IBOutlet private(set) var cvMovieListing: UICollectionView!
    @IBOutlet private(set) var btnBack: UIButton!
    @IBOutlet private(set) var txtSearch: UISearchBar!
    
    private var isSearching: Bool = false
    private var viewModel: MoviesSearchViewModel
    
    init?(viewModel: MoviesSearchViewModel, coder: NSCoder) {
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
    
    private func setupUI() {
        cvMovieListing.delegate = self
        cvMovieListing.dataSource = dataSource
        cvMovieListing.register(UINib(nibName: MovieCell.cellID, bundle: nil), forCellWithReuseIdentifier: MovieCell.cellID)
        txtSearch.delegate = self
        searching(isStart: true)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        
    }
    
    //MARK: - Actions
    @IBAction func btnBackTap(_ sender: UIButton) {
        
        searching(isStart: false)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension MoviesSearchViewController{
    func bind() {
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

extension MoviesSearchViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.preload()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
}

extension MoviesSearchViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath)?.preload()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
}


private extension MoviesSearchViewController{
    private func cellController(forRowAt indexPath: IndexPath) -> MoviesCellController? {
        let controller = dataSource.itemIdentifier(for: indexPath)
        return controller
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.cancelLoad()
    }
    
}

extension MoviesSearchViewController: UICollectionViewDelegateFlowLayout {
    
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

private extension MoviesSearchViewController{
    func searching(isStart: Bool) {
        self.txtSearch.isHidden = !isStart
        _ = isStart ? txtSearch.becomeFirstResponder() : txtSearch.resignFirstResponder()
        
        txtSearch.text = ""
       
    }
}

extension MoviesSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count >= 2 {
            isSearching = true
            viewModel.searchMovies(searchText)
        }
    }
}
