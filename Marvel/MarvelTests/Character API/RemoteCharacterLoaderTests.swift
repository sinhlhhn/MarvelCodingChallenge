//
//  RemoteCharacterLoaderTests.swift
//  RemoteCharacterLoaderTests
//
//  Created by Sam on 26/10/2023.
//

import XCTest
import Marvel

class RemoteCharacterLoaderTests: XCTestCase {
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        [100, 199, 201, 300, 500].enumerated().forEach { index, statusCode in
            expect(sut, completionWith: .failure(anyNSError())) {
                client.completionWith(statusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        let invalidData = Data()
        
        expect(sut, completionWith: .failure(anyNSError())) {
            client.completionWith(data: invalidData)
        }
    }
    
    func test_load_deliversNoItemOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let emptyJSONList = Data("{\"data\":{\"results\":[], \"offset\":0, \"total\":1}}".utf8)
        
        expect(sut, completionWith: .success(makePaginated(items: []))) {
            client.completionWith(data: emptyJSONList)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let (item0, item0JSON) = makeCharacterJSONItem(id: 0, name: "Iron man", thumbnail: "http://any-url0.com")
        let (item1, item1JSON) = makeCharacterJSONItem(id: 1, name: "Spider man", thumbnail: "http://any-url1.com")
        
        let itemsJSON = [
            "results": [item0JSON, item1JSON],
            "offset": 0,
            "total": 1
        ] as [String : Any]
        
        let responseJSON = [
            "data": itemsJSON
        ]
        
        let json = try! JSONSerialization.data(withJSONObject: responseJSON)
        
        expect(sut, completionWith: .success(makePaginated(items: [item0, item1]))) {
            client.completionWith(data: json)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT() -> (RemoteLoader<Paginated>, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<Paginated>(client: client, mapper: CharacterMapper.map)
        
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
    
    private func expect(_ sut: RemoteLoader<Paginated>, completionWith expectedResult: Result<Paginated, Error>, action: (() -> Void), file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://any-url.com")!
        let exp = expectation(description: "wait for completion")
        
        sut.load(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(item), .success(expectedItem)):
                XCTAssertEqual(item, expectedItem, file: file, line: line)
            case let (.failure(error), .failure(expectedError)):
                XCTAssertNotNil(error, file: file, line: line)
                XCTAssertNotNil(expectedError, file: file, line: line)
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
