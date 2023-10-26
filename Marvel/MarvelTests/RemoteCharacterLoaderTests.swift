//
//  RemoteCharacterLoaderTests.swift
//  RemoteCharacterLoaderTests
//
//  Created by Sam on 26/10/2023.
//

import XCTest
import Marvel

class RemoteCharacterLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteCharacterLoader.Error?
        
        let exp = expectation(description: "wait for completion")
        sut.load(from: url) { result in
            switch result {
            case .success(let item):
                XCTFail("Expected failure got \(item) instead")
            case .failure(let error):
                capturedError = error
            }
            exp.fulfill()
        }
        
        let error = NSError(domain: "client", code: 0)
        client.completionWith(error: error)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        var capturedError: RemoteCharacterLoader.Error?
        
        let exp = expectation(description: "wait for completion")
        sut.load(from: url) { result in
            switch result {
            case .success(let item):
                XCTFail("Expected failure got \(item) instead")
            case .failure(let error):
                capturedError = error
            }
            exp.fulfill()
        }
        
        client.completionWith(errorCode: 300)
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(capturedError, .invalidData)
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (RemoteCharacterLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)] = []
        
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(url: URL, completion: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)) {
            messages.append((url, completion))
        }
        
        func completionWith(error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func completionWith(errorCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: errorCode, httpVersion: nil, headerFields: nil)!
            let data = Data()
            messages[index].completion(.success((data, response)))
        }
    }
}
