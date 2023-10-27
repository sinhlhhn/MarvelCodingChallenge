//
//  CharacterDetailItem.swift
//  Marvel
//
//  Created by Sam on 27/10/2023.
//

import Foundation

public struct CharacterDetailItem: Hashable {
    public let id: Int
    public let name: String
    public let thumbnail: URL
    public let comicNames: [String]
    
    public init(id: Int, name: String, thumbnail: URL, comicNames: [String]) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.comicNames = comicNames
    }
}
