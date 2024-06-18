//
//  MoviesSearchViewController+Ext.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 17/06/24.
//

import Foundation
import UIKit
@testable import DiagnalApp

extension MoviesSearchViewController{
    public override func loadViewIfNeeded() {
      super.loadViewIfNeeded()
      
      // make view small to prevent rendering cells
        cvMovieListing.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    var numberOfItems: Int {
      return cvMovieListing.numberOfSections == 0 ? 0 : cvMovieListing.numberOfItems(inSection: 0)
    }
    
    func itemAt(_ item: Int, section: Int = 0) -> UICollectionViewCell? {
      let dataSource = cvMovieListing.dataSource
      let indexPath = IndexPath(item: item, section: section)
      return dataSource?.collectionView(cvMovieListing, cellForItemAt: indexPath)
    }
    
    @discardableResult
    func simulateItemVisible(at index: Int) -> UICollectionViewCell? {
      let cell = itemAt(index)!
      let delegate = cvMovieListing.delegate
      let indexPath = IndexPath(item: index, section: 0)
      delegate?.collectionView?(cvMovieListing, willDisplay: cell, forItemAt: indexPath)
      return cell
    }

    @discardableResult
    func simulateItemNotVisible(at index: Int) -> UICollectionViewCell? {
      let view = simulateItemVisible(at: index)

      let delegate = cvMovieListing.delegate
      let indexPath = IndexPath(item: index, section: 0)
      delegate?.collectionView?(cvMovieListing, didEndDisplaying: view!, forItemAt: indexPath)

      return view
    }

    func simulateItemNearVisible(at index: Int) {
      let prefetchDataSource = cvMovieListing.prefetchDataSource
      let indexPath = IndexPath(item: index, section: 0)
      prefetchDataSource?.collectionView(cvMovieListing, prefetchItemsAt: [indexPath])
    }
    
    func simulateItemNoLongerNearVisible(at index: Int) {
      simulateItemNearVisible(at: index)
      let prefetchDataSource = cvMovieListing.prefetchDataSource
      let indexPath = IndexPath(item: index, section: 0)
      prefetchDataSource?.collectionView?(cvMovieListing, cancelPrefetchingForItemsAt: [indexPath])
    }
    
    func simulateAppearance(){
        if !isViewLoaded{
            loadViewIfNeeded()            
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}
