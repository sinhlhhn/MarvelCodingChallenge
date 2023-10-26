//
//  RemoteCharacterLoaderTests.swift
//  RemoteCharacterLoaderTests
//
//  Created by Sam on 26/10/2023.
//

import XCTest

class RemoteCharacterLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL) {
        client.get(url: url)
    }
}

protocol HTTPClient {
    func get(url: URL)
}

class RemoteCharacterLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestURL() {
        let client = HTTPClientSpy()
        _ = RemoteCharacterLoader(client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsURL() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(client: client)
        
        sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        
        func get(url: URL) {
            requestedURLs.append(url)
        }
    }
}
