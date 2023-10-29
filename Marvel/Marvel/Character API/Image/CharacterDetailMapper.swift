//
//  CharacterDetailMapper.swift
//  Marvel
//
//  Created by Sam on 27/10/2023.
//

import Foundation

public final class CharacterDetailMapper {
    private init() {}
    
    private static let isOK = 200
    
    struct Root: Codable {
        let data: DataClass
        
        struct DataClass: Codable {
            let results: [Character]
        }

        struct Character: Codable {
            private let id: Int
            private let name: String
            private let thumbnail: Thumbnail
            private let comics: Comics
            
            var characterDetailItem: CharacterDetailItem{
                CharacterDetailItem(
                    id: id,
                    name: name,
                    thumbnail: thumbnail.url,
                    comicNames: comics.items.map { $0.name })
            }
        }
        
        private struct Comics: Codable {
            let items: [ComicsItem]
        }
        
        private struct ComicsItem: Codable {
            let name: String
        }

        private struct Thumbnail: Codable {
            let path: String
            let fileExtension: String
            
            var url: URL {
                URL(string: "\(path).\(fileExtension)")!
            }
            
            enum CodingKeys: String, CodingKey {
                case path
                case fileExtension = "extension"
            }
        }
    }
    
    private struct InvalidData: Error {}
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) -> Result<CharacterDetailItem, Error> {
        if response.statusCode == isOK, let root = try? JSONDecoder().decode(Root.self, from: data), let result = root.data.results.first {
            return .success(result.characterDetailItem)
        } else {
            return .failure(RemoteCharacterLoader.Error.invalidData)
        }
    }
}
