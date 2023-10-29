//
//  RemoteCharacterDetailLoader.swift
//  Marvel
//
//  Created by Sam on 29/10/2023.
//

import Foundation

public final class RemoteCharacterDetailLoader: CharacterDetailLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(from url: URL, completion: @escaping ((Result<CharacterDetailItem, Swift.Error>) -> Void)) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(CharacterDetailMapper.map(data, response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}
