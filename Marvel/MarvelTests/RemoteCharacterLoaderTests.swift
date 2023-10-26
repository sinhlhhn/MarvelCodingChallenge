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
        let (sut, client) = makeSUT()
        
        expect(sut, completionWith: .failure(.connectivity)) {
            let error = NSError(domain: "client", code: 0)
            client.completionWith(error: error)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        [100, 199, 201, 300, 500].enumerated().forEach { index, statusCode in
            expect(sut, completionWith: .failure(.invalidData)) {
                client.completionWith(statusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        let invalidData = Data()
        
        expect(sut, completionWith: .failure(.invalidData)) {
            client.completionWith(data: invalidData)
        }
    }
    
    func test_load_deliversNoItemOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let emptyJSONList = Data("{\"data\":{\"results\":[]}}".utf8)
        
        expect(sut, completionWith: .success([])) {
            client.completionWith(data: emptyJSONList)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let (item0, item0JSON) = makeCharacterJSONItem(id: 0, name: "Iron man", thumbnail: URL(string: "http://any-url0.com")!)
        let (item1, item1JSON) = makeCharacterJSONItem(id: 1, name: "Spider man", thumbnail: URL(string: "http://any-url1.com")!)
        
        let itemsJSON = [
            "results": [item0JSON, item1JSON]
        ]
        
        let responseJSON = [
            "data": itemsJSON
        ]
        
        let json = try! JSONSerialization.data(withJSONObject: responseJSON)
        
        expect(sut, completionWith: .success([item0, item1])) {
            client.completionWith(data: json)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (RemoteCharacterLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(client: client)
        
        return (sut, client)
    }
    
    private func makeCharacterJSONItem(id: Int, name: String, thumbnail: URL) -> (model: CharacterItem, json: [String: Any]) {
        let item = CharacterItem(id: id, name: name, thumbnail: thumbnail)
        
        let thumbnailJSON = [
            "path": item.thumbnail.absoluteString
        ]
        
        let itemJSON = [
            "id": item.id,
            "name": item.name,
            "thumbnail": thumbnailJSON
        ] as [String : Any]
        
        return (item, itemJSON)
    }
    
    private func expect(_ sut: RemoteCharacterLoader, completionWith expectedResult: Result<[CharacterItem], RemoteCharacterLoader.Error>, action: (() -> Void), file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://any-url.com")!
        let exp = expectation(description: "wait for completion")
        
        sut.load(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(item), .success(expectedItem)):
                XCTAssertEqual(item, expectedItem, file: file, line: line)
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
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
        
        func completionWith(statusCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            let data = Data()
            messages[index].completion(.success((data, response)))
        }
        
        func completionWith(data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: 200, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
