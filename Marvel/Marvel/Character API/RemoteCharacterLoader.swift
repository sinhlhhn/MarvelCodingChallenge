//
//  RemoteCharacterLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(from url: URL, completion: @escaping ((Result<[CharacterItem], Swift.Error>) -> Void)) {
        client.get(url: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(CharacterMapper.map(data, response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}
