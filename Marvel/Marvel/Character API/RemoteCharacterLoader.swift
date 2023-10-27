//
//  RemoteCharacterLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Result<[CharacterItem], Swift.Error>) -> Void)) {
        client.get(from: url) { [weak self] result in
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
