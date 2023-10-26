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
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.load(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (RemoteCharacterLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] = []
        
        func get(url: URL) {
            requestedURLs.append(url)
        }
    }
}
