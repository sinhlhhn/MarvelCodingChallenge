//
//  CharacterEndpointTests.swift
//  MarvelTests
//
//  Created by Sam on 26/10/2023.
//

import XCTest
import Marvel

final class CharacterEndpointTests: XCTestCase {
    func test_character_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let receive = CharacterEndpoint.get.url(baseURL: baseURL)
        
        XCTAssertEqual(receive.scheme, "http", "scheme")
        XCTAssertEqual(receive.host, "base-url.com", "host")
        XCTAssertEqual(receive.path, "/v1/public/characters", "path")
        XCTAssertEqual(receive.query?.contains("apikey"), true, "apikey query")
        XCTAssertEqual(receive.query?.contains("ts"), true, "ts query")
        XCTAssertEqual(receive.query?.contains("hash"), true, "hash query")
    }
}

