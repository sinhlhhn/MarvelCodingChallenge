//
//  CharacterDetailViewModel.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import SwiftUI
import Marvel

public class CharacterDetailViewModel: ObservableObject {
    private let loader: CharacterDetailLoader
    private let url: URL
    
    enum State {
        case loading
        case success(CharacterDetailItem)
        case failure(String)
    }
    
    @Published var state: State = .loading
    
    public init(url: URL, loader: CharacterDetailLoader) {
        self.loader = loader
        self.url = url
    }
    
    func loadData() {
        state = .loading
        loader.load(from: url) { [weak self] result in
            switch result {
            case let .success(item):
                self?.state = .success(item)
            case let .failure(error):
                self?.state = .failure(error.localizedDescription)
            }
        }
    }
}
