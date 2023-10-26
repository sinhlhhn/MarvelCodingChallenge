//
//  RemoteCharacterLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL, completion: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void))
}

public final class RemoteCharacterLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(from url: URL, completion: @escaping ((Result<[CharacterItem], Error>) -> Void)) {
        client.get(url: url) { result in
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.characterItems))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}

struct Root: Codable {
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


