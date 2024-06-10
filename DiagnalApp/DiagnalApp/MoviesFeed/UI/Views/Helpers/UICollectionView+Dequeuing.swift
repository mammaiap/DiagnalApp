//
//  UICollectionView+Dequeuing.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)        
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }
}
