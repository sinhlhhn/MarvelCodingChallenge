//
//  MainQueueDispatchDecorator.swift
//  MarvelApp
//
//  Created by Sam on 27/10/2023.
//

import Foundation
import Marvel

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
    }
}

extension MainQueueDispatchDecorator: CharacterImageDataLoader where T == CharacterImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> ()) -> CharacterImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: CharacterLoader where T == CharacterLoader {
    
    func load(from url: URL, completion: @escaping ((Result<Paginated, Error>) -> Void)) {
        decoratee.load(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: HTTPClient where T == HTTPClient {
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        decoratee.get(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
