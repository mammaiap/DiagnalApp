//
//  Localized.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

final class Localized {
    static var bundle: Bundle {
        Bundle(for: Localized.self)
    }
}

extension Localized {
    enum MoviesFeed {
        static var table: String { "MoviesFeed" }

        static var loadError: String {
            NSLocalizedString(
                "text.feed.load.error",
                tableName: table,
                bundle: bundle,
                comment: "Error message displayed when we can't load the movies feed from the JSON file")
        }
        
        static var errorTitle: String {
            NSLocalizedString(
                "text.feed.error.title",
                tableName: table,
                bundle: bundle,
                comment: "Error Alert Title")
        }
        
        static var errorOKButtonText: String {
            NSLocalizedString(
                "text.feed.error.ok",
                tableName: table,
                bundle: bundle,
                comment: "Error Alert OK button text")
        }
        
        
        
    }
}
