//
//  MoviesFeedMapper.swift
//  DiagnalApp
//
//  Created by Muthulingam on 10/06/24.
//

import Foundation

final class MoviesFeedMapper {
    private init(){}
    
    struct RemoteMoviesFeed: Codable {
        var page: Page? = Page()
        
        enum CodingKeys: String, CodingKey {
            case page = "page"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            page = try values.decodeIfPresent(Page.self , forKey: .page )
            
        }
        
        init() {
            
        }
        
        struct Page: Codable{
            var title: String?
            var totalContentItems: Int?
            var pageNum: Int?
            var pageSize: Int?
            var contentItems: ContentItems? = ContentItems()
            
            enum CodingKeys: String, CodingKey {
                case title               = "title"
                case totalContentItems = "total-content-items"
                case pageNum            = "page-num"
                case pageSize           = "page-size"
                case contentItems       = "content-items"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                
                title              = try values.decodeIfPresent(String.self        , forKey: .title              )
                contentItems       = try values.decodeIfPresent(ContentItems.self  , forKey: .contentItems       )
                
                if let stringVal = try values.decodeIfPresent(String.self, forKey: .totalContentItems), let intVal = Int(stringVal) {
                    totalContentItems = intVal
                } else {
                    totalContentItems = 0
                }
                
                if let stringVal = try values.decodeIfPresent(String.self, forKey: .pageNum), let intVal = Int(stringVal) {
                    pageNum = intVal
                } else {
                    pageNum = 0
                }

                if let stringVal = try values.decodeIfPresent(String.self, forKey: .pageSize), let intVal = Int(stringVal) {
                    pageSize = intVal
                } else {
                    pageSize = 0
                }
                
            }
            
            init() {
                
            }
            
        }
        
        
        struct ContentItems: Codable {
            var content: [Content]? = []
            
            enum CodingKeys: String, CodingKey {
                case content = "content"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                content = try values.decodeIfPresent([Content].self , forKey: .content )
                
            }
            
            init() {
                
            }
            
        }
        
        struct Content: Codable {
            var name: String?
            var posterImage: String?
            
            enum CodingKeys: String, CodingKey {
                case name         = "name"
                case posterImage  = "poster-image"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                
                name         = try values.decodeIfPresent(String.self , forKey: .name        )
                posterImage  = try values.decodeIfPresent(String.self , forKey: .posterImage )
                
            }
            
            init() {
                
            }
            
        }
        
        var asPageDTO: MoviesFeed {
            return MoviesFeed(title: page?.title ?? "",
                              totalContentItems: page?.totalContentItems ?? 0,
                              pageNum: page?.pageNum ?? 0,
                              pageSize: page?.pageSize ?? 0,
                              items: page?.contentItems?.content?.asCardDTO ?? [])
        }
        
    }
    
    static func map(_ data: Data) throws -> MoviesFeed {
        guard let page = try? JSONDecoder().decode(RemoteMoviesFeed.self, from: data) else {
            throw RemoteMockedMoviesFeedLoader.Error.parseError
        }

        return page.asPageDTO
    }
    
}

private extension Array where Element == MoviesFeedMapper.RemoteMoviesFeed.Content {
  var asCardDTO: [MoviesCard] {
      return map { MoviesCard(name: $0.name ?? "", posterImage: $0.posterImage ?? "") }
  }
}
