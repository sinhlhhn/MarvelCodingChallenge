//
//  RemoteCharacterLoaderTests.swift
//  RemoteCharacterLoaderTests
//
//  Created by Sam on 26/10/2023.
//

import XCTest

class RemoteCharacterLoader {
    
}

protocol HTTPClient {
    func get(url: URL)
}

class RemoteCharacterLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestURL() {
        let client = HTTPClientSpy()
        _ = RemoteCharacterLoader()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        
        func get(url: URL) {
            
        }
    }
}
