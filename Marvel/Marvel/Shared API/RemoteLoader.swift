//
//  RemoteLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public final class RemoteLoader<Item> {
    public typealias Mapper = ((Data, HTTPURLResponse) -> Result<Item, Swift.Error>)
    
    private let client: HTTPClient
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, mapper: @escaping Mapper) {
        self.client = client
        self.mapper = mapper
    }
    
    public func load(from url: URL, completion: @escaping ((Result<Item, Swift.Error>) -> Void)) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)):
                completion(mapper(data, response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
}
