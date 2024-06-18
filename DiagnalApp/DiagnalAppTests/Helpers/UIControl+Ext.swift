//
//  UIControl+Ext.swift
//  DiagnalAppTests
//
//  Created by Muthulingam on 16/06/24.
//

import Foundation
import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
