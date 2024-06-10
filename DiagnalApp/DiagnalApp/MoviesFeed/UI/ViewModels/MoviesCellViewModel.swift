//
//  MoviesCellViewModel.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

final class MoviesCellViewModel{
    private let model: MoviesCard
    
    init(model: MoviesCard) {
        self.model = model
    }
    
}

extension MoviesCellViewModel{
    var name: String{
        return model.name
    }
    
    var posterImageFileName: String{        
        var filename = model.posterImage
        if(filename == "posterthatismissing.jpg"){
            filename = "placeholder_for_missing_posters.png"
        }
        return filename
    }
}
