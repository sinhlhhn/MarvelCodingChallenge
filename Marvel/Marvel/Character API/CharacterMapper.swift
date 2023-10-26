//
//  CharacterMapper.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

final class CharacterMapper {
    private init() {}
    
    private static let isOK = 200
    
    private struct Root: Codable {
        private let data: DataClass
        
        var characterItems: [CharacterItem] {
            data.results.map {
                CharacterItem(id: $0.id, name: $0.name, thumbnail: URL(string: $0.thumbnail.path)!)
            }
        }
        
        private struct DataClass: Codable {
            let results: [Character]
        }

        private struct Character: Codable {
            let id: Int
            let name: String
            let thumbnail: Thumbnail
        }

        private struct Thumbnail: Codable {
            let path: String
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> Result<[CharacterItem], Error> {
        if response.statusCode == isOK, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.characterItems)
        } else {
            return .failure(RemoteCharacterLoader.Error.invalidData)
        }
    }
}
