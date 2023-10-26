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
    
    private var publicKey: String { "" }
    private var privateKey: String { "" }
    
    public func url(baseURL: URL) -> URL {
        switch self {
            case .get:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host()
            components.path = baseURL.path() + "/v1/public/characters"
            components.queryItems = makeQueries()
            
            return components.url!
        }
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
