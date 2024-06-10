//
//  UIFont+Ext.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation
import UIKit

public extension UIFont {

  static let loadCustomFonts: () = {
    loadFontWith(name: "TitilliumWeb-Light")
    loadFontWith(name: "TitilliumWeb-Regular")
  }()

  enum FontWeight {
    case light
    case regular
  }

  static func custom(_ weight: FontWeight, size: CGFloat) -> UIFont {
    switch weight {
      case .light:
        return UIFont(name: "TitilliumWeb-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
      case .regular:
        return UIFont(name: "TitilliumWeb-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
      
    }
  }


}

private extension UIFont {

  private class Typography { }

  static func loadFontWith(name: String) {
    let frameworkBundle = Bundle(for: Typography.self)
    let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "ttf")
    let fontData = NSData(contentsOfFile: pathForResourceString!)
    let dataProvider = CGDataProvider(data: fontData!)
    let fontRef = CGFont(dataProvider!)
    var errorRef: Unmanaged<CFError>? = nil

    if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
      NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
    }
  }
}
