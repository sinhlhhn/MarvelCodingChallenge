//
//  CharacterItem.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public struct Paginated {
    public let characters: [CharacterItem]
    public let isLast: Bool
}

public struct CharacterItem: Hashable {
    public let id: Int
    public let name: String
    public let thumbnail: URL
    
    public init(id: Int, name: String, thumbnail: URL) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
    }
}
