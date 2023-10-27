//
//  RemoteImageLoader.swift
//  Marvel
//
//  Created by Sam on 27/10/2023.
//

import Foundation

public class RemoteImageLoader: CharacterImageDataLoader {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }
    
    private class UnexpectedValuesRepresentation: Error {}
    
    private class RemoteCharacterImageDataLoaderTask: CharacterImageDataLoaderTask {
        private var completion: ((CharacterImageDataLoader.Result) -> ())?
        
        init(completion: @escaping (CharacterImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: CharacterImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    
    public func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> ()) -> CharacterImageDataLoaderTask {
        let task = RemoteCharacterImageDataLoaderTask(completion: completion)
        
        session.dataTask(with: url) { data, response, error in
            task.complete(with: Result(catching: {
                if let error = error {
                    throw error
                } else if let data = data {
                    return data
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            }))
        }.resume()
        
        return task
    }
}
