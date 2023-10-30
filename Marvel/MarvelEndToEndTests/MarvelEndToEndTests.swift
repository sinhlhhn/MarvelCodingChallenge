//
//  MarvelEndToEndTests.swift
//  MarvelEndToEndTests
//
//  Created by Sam on 26/10/2023.
//

import XCTest
import Marvel

final class MarvelEndToEndTests: XCTestCase {
    
    func test_endToEnd() {
        let receivedResult = getFromURL()
        
        switch receivedResult {
        case let .success(items):
            XCTAssertEqual(items.characters.count, 20)
            for index in 0...4 {
                XCTAssertEqual(items.characters[index].id, id(at: index))
                XCTAssertEqual(items.characters[index].name, name(at: index))
                XCTAssertEqual(items.characters[index].thumbnail, thumbnail(at: index))
            }
        case let .failure(error):
            XCTFail("Expected success, got error \(error)")
        default:
            XCTFail("Expected success, got result \(String(describing: receivedResult))")
        }
    }

    //MARK: -Helpers
    
    private func getFromURL(file: StaticString = #filePath,
                            line: UInt = #line) -> Swift.Result<Paginated, Error>? {
        let url = characterTestServerURL
        let client = ephemeralClient()
        
        var receivedResult: Swift.Result<Paginated, Error>?
        
        let exp = expectation(description: "Wait for completion")
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                receivedResult = CharacterMapper.map(data, response)
            case let .failure(error):
                receivedResult = .failure(error)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10)
        
        return receivedResult
    }
    
    private var characterTestServerURL: URL {
        return CharacterEndpoint.get(0).url(baseURL: URL(string: "https://gateway.marvel.com:443")!)
    }
    
    private func ephemeralClient(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        trackForMemoryLeak(client, file: file, line: line)
        
        return client
    }
    
    private func id(at index: Int) -> Int {
            return [
                1011334,
                1017100,
                1009144,
                1010699,
                1009146
            ][index]
        }

        private func name(at index: Int) -> String? {
            return [
                "3-D Man",
                "A-Bomb (HAS)",
                "A.I.M.",
                "Aaron Stack",
                "Abomination (Emil Blonsky)"
            ][index]
        }

        private func thumbnail(at index: Int) -> URL {
            return [
                URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784.jpg")!,
                URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/3/20/5232158de5b16.jpg")!,
                URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/6/20/52602f21f29ec.jpg")!,
                URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg")!,
                URL(string: "http://i.annihil.us/u/prod/marvel/i/mg/9/50/4ce18691cbf04.jpg")!
            ][index]
        }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath,
                                    line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should has been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
