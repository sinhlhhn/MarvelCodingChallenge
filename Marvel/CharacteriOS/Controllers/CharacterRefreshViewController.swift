//
//  CharacterRefreshViewController.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit
import Marvel

public final class CharacterRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let characterLoader: CharacterLoader

    public init(characterLoader: CharacterLoader) {
        self.characterLoader = characterLoader
    }

    public var onRefresh: (([CharacterItem]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()
        characterLoader.load { [weak self] result in
            DispatchQueue.main.async {
                if let items = try? result.get() {
                    self?.onRefresh?(items)
                }
                self?.view.endRefreshing()
            }
        }
    }
}
