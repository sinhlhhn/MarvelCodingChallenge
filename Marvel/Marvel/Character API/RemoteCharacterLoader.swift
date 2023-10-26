//
//  RemoteCharacterLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL)
}

public final class RemoteCharacterLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(from url: URL) {
        client.get(url: url)
    }
}
