//
//  CharacterLoadMoreViewController.swift
//  CharacteriOS
//
//  Created by Sam on 29/10/2023.
//

import UIKit
import Marvel

public final class CharacterLoadMoreViewController {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()

    private let characterLoader: CharacterLoader

    public init(characterLoader: CharacterLoader) {
        self.characterLoader = characterLoader
    }

    public var onRefresh: ((Paginated) -> Void)?
    public var onError: ((String?) -> Void)?
    public var onLoadMore: ((Int) -> Void)?

    public func loadMore(url: URL) {
        if view.isRefreshing { return }
        onError?(nil)
        view.beginRefreshing()
        
        characterLoader.load(from: url, completion: { [weak self]  result in
            switch result {
            case let .success(items):
                self?.onRefresh?(items)
            case let .failure(error):
                self?.onError?(error.localizedDescription)
            }
            self?.view.endRefreshing()
        })
    }
    
    func loadMore(page: Int) {
        onLoadMore?(page + 1)
    }
}
