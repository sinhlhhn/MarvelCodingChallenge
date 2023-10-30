//
//  CharacterMapper.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public final class CharacterMapper {
    private init() {}
    
    private static let isOK = 200
    
    private struct Root: Codable {
        let data: DataClass
        
        struct DataClass: Codable {
            let results: [Character]
            let offset: Int
            let total: Int
            
            var characterItems: Paginated {
                Paginated(
                    characters: results.map {
                    CharacterItem(id: $0.id, name: $0.name, thumbnail: $0.thumbnail.url)
                },
                    isLast: offset == total)
                
            }
        }

        struct Character: Codable {
            let id: Int
            let name: String
            let thumbnail: Thumbnail
        }

        struct Thumbnail: Codable {
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
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, _ response: HTTPURLResponse) -> Result<Paginated, Swift.Error> {
        if response.statusCode == isOK, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.data.characterItems)
        } else {
            return .failure(Error.invalidData)
        }
    }
}
