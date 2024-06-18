//
//  UIRefreshControl+Ext.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 16/06/24.
//

import Foundation
import UIKit

extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}

