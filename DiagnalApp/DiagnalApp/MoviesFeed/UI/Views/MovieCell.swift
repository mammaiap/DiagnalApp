//
//  MovieCell.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import UIKit

final class MovieCell: UICollectionViewCell { 
    
    //MARK: - Outlets
    @IBOutlet private(set) var imgMoviePoster: UIImageView!
    @IBOutlet private(set) var lblMovieName: UILabel!
    
    static let cellID = "MovieCell"
    
}
