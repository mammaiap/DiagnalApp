//
//  UILabel+Extension.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

extension UILabel {

    var isTruncated: Bool {

        guard let labelText = text else {
            return false
        }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font ?? UIFont.custom(.regular, size: 14)],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }
}

extension UILabel {
    func startMarqueeAnimation() {
        // Add marquee animation code here
        let labelWidth = self.bounds.width
        let textWidth = self.intrinsicContentSize.width
        let duration = Double(textWidth / labelWidth) * 5.0 // Adjust the multiplier for animation speed

        let animation = CABasicAnimation(keyPath: "position.x")
        animation.fromValue = self.layer.position.x
        animation.toValue = -(textWidth / 2)
        animation.duration = duration
        animation.repeatCount = .infinity
        self.layer.add(animation, forKey: "marqueeAnimation")
    }

    func stopMarqueeAnimation() {
        self.layer.removeAnimation(forKey: "marqueeAnimation")
    }
}
