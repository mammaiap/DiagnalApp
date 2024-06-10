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
    
    var filteredCollectionModel = [MoviesCellController](){
        didSet {
            cvMovieListing.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        cvMovieListing.delegate = self
        cvMovieListing.dataSource = self
        cvMovieListing.register(UINib(nibName: MovieCell.cellID, bundle: nil), forCellWithReuseIdentifier: MovieCell.cellID)
        txtSearch.delegate = self
        searching(isStart: true)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.isHidden = true
        
    }
    
    //MARK: - Actions
    @IBAction func btnBackTap(_ sender: UIButton) {
        // pop to MoviesFeedViewController
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

extension MoviesSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCollectionModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        return cellController(forRowAt: indexPath).view(in: collectionView, for: indexPath)
    }    
    
}

private extension MoviesSearchViewController{
    private func cellController(forRowAt indexPath: IndexPath) -> MoviesCellController {
        return filteredCollectionModel[indexPath.row]
        
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
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

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
            
            self.txtSearch.isHidden = !isStart
            
            self.view.layoutIfNeeded()
        }, completion: nil)
        
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
