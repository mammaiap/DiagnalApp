//
//  MoviesCellController.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

final class MoviesCellController: Hashable, Equatable {
    
    private let viewModel: MoviesCellViewModel
    private var cell: MovieCell?
    
    init(viewModel: MoviesCellViewModel) {
        self.viewModel = viewModel
    }
    
    var movieName: String{
        return viewModel.name
    }
    
    func view(in collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = binded(collectionView.dequeueReusableCell(for: indexPath))
        return cell
    }
    
    func preload() {
      // if any heavy prefetching is required here we can do that.. like thumbnail fetching with remote API.. 
    }

    func cancelLoad() {
        releaseCellForReuse()
     
    }
    
    private func binded(_ cell: MovieCell) -> MovieCell {
        self.cell = cell
        cell.lblMovieName.text = viewModel.name
        if cell.lblMovieName.isTruncated {
            cell.lblMovieName.startMarqueeAnimation()
        } else {           
            cell.lblMovieName.stopMarqueeAnimation()
        }
        cell.imgMoviePoster.setImageAnimated(UIImage(named: viewModel.posterImageFileName))
        
        return cell
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
    
    static func == (lhs: MoviesCellController, rhs: MoviesCellController) -> Bool {
        lhs.viewModel.name == rhs.viewModel.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.name)
    }
    
    
    
}
