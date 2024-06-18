//
//  UIButton+Ext.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 17/06/24.
//

import Foundation
import UIKit

extension UIButton {
  func simulateTap() {
    simulate(event: .touchUpInside)
  }
}
