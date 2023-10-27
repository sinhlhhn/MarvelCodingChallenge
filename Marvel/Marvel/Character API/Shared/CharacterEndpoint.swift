//
//  CharacterEndpoint.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation
import CryptoKit

public enum CharacterEndpoint {
    case get
    case getDetail(CharacterItem)
    
    private var publicKey: String { "15d403f63d44d387609f44740a90a18b" }
    private var privateKey: String { "3d21f30d1b17d7ec79192adf9d03f532b017210e" }
    
    public func url(baseURL: URL) -> URL {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host()
        components.queryItems = makeQueries()
        switch self {
        case .get:
            components.path = baseURL.path() + "/v1/public/characters"
        case let .getDetail(item):
            components.path = baseURL.path() + "/v1/public/characters/\(item.id)"
        }
        return components.url!
    }
    
    private func makeQueries() -> [URLQueryItem] {
        let ts = String(Date().timeIntervalSince1970)
        let digest = Insecure.MD5.hash(data: Data("\(ts)\(privateKey)\(publicKey)".utf8))
        let hash = digest.map {
            String(format: "%02hhx", $0)
        }.joined()
        
        return [
            URLQueryItem(name: "apikey", value: publicKey),
            URLQueryItem(name: "ts", value: ts),
            URLQueryItem(name: "hash", value: hash),
        ]
    }
}
