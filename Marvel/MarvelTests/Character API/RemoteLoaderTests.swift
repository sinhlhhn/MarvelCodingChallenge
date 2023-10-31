//
//  RemoteLoaderTests.swift
//  MarvelTests
//
//  Created by Sam on 31/10/2023.
//

import XCTest
import Marvel

class RemoteLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT()
        
        sut.load(from: url) { _ in }
        sut.load(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, completionWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.completionWith(error: clientError)
        }
    }
        
    func test_load_deliversErrorOnMapperError() {
        let anyData = Data("any".utf8)
        let (sut, client) = makeSUT(mapper: { _, _ in
                .failure(RemoteLoader<String>.Error.invalidData)
        })
        
        expect(sut, completionWith: .failure(.invalidData)) {
            client.completionWith(data: anyData)
        }
    }
        
    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
                .success(String(data: data, encoding: .utf8)!)
        })
        
        expect(sut, completionWith: .success(resource)) {
            client.completionWith(data: Data(resource.utf8))
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(client: client, mapper: { _, _ in .success("any") })
        
        var capturedResults = [Result<String, Error>]()
        sut?.load(from: url) { capturedResults.append($0) }

        sut = nil
        client.completionWith(data: Data())
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in .success("any")}) -> (RemoteLoader<String>, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(client: client, mapper: mapper)
        
        return (sut, client)
    }
               
    private func makePaginated(items: [CharacterItem]) -> Paginated {
        Paginated(characters: items, isLast: false)
    }
    
    private func makeCharacterJSONItem(id: Int, name: String, thumbnail: String) -> (model: CharacterItem, json: [String: Any]) {
        let fileExtension = "jpg"
        let thumbnailURL = URL(string: "\(thumbnail).\(fileExtension)")!
        let item = CharacterItem(id: id, name: name, thumbnail: thumbnailURL)
        
        let thumbnailJSON = [
            "path": thumbnail,
            "extension": fileExtension
        ]
        
        let itemJSON = [
            "id": item.id,
            "name": item.name,
            "thumbnail": thumbnailJSON
        ] as [String : Any]
        
        return (item, itemJSON)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "NSError", code: 0)
    }
    
    private func expect(_ sut: RemoteLoader<String>, completionWith expectedResult: Result<String, RemoteLoader<String>.Error>, action: (() -> Void), file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://any-url.com")!
        let exp = expectation(description: "wait for completion")
        
        sut.load(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(item), .success(expectedItem)):
                XCTAssertEqual(item, expectedItem, file: file, line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
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
        
        func get(from url: URL, completion: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void)) {
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
