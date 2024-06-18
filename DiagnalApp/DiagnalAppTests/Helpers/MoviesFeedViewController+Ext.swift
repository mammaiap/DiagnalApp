//
//  MoviesFeedViewController+Ext.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 16/06/24.
//

import Foundation
import UIKit
@testable import DiagnalApp

extension MoviesFeedViewController{
    public override func loadViewIfNeeded() {
      super.loadViewIfNeeded()
      
      // make view small to prevent rendering cells
        cvMovieListing.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserRefresh() {
        cvMovieListing.refreshControl?.beginRefreshing()
        self.scrollViewDidEndDragging(cvMovieListing, willDecelerate: true)
    }
    
    var loadingIndicatorIsVisible: Bool {
      return cvMovieListing.refreshControl?.isRefreshing == true
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
    
    func simulatePagingRequest() {
      let scrollView = DraggingScrollView()
      scrollView.contentOffset.y = 1000
      scrollViewDidScroll(scrollView)
    }
    
    func simulateOnSeachButtonTap() {        
        btnSearch.sendActions(for: .touchUpInside)
    }

    
    func simulateAppearance(){
        if !isViewLoaded{
            loadViewIfNeeded()
            replaceRefreshControlWithFake()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFake(){
        let fake = FakeRefreshControl()
        
        
        cvMovieListing.refreshControl?.allTargets.forEach { target in
            cvMovieListing.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        cvMovieListing.refreshControl = fake
    }
}

private class FakeRefreshControl: UIRefreshControl{
    
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}

private class DraggingScrollView: UIScrollView {
  override var isDragging: Bool {
    true
  }
}


