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
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(from url: URL, completion: @escaping ((Result<CharacterItem, Error>) -> Void)) {
        client.get(url: url) { _ in
            completion(.failure(.connectivity))
        }
    }
}
