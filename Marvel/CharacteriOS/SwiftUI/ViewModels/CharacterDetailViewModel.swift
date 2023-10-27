//
//  CharacterDetailViewModel.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import SwiftUI
import Marvel

public class CharacterDetailViewModel: ObservableObject {
    private let client: HTTPClient
    private let url: URL
    
    enum State {
        case loading
        case success(CharacterDetailItem)
        case failure(String)
    }
    
    @Published var state: State = .loading
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func loadData() {
        state = .loading
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                do {
                    self?.state = .success(try CharacterDetailMapper.map(data, response))
                } catch {
                    self?.state = .failure(error.localizedDescription)
                }
            case let .failure(error):
                self?.state = .failure(error.localizedDescription)
            }
        }
        
    }
}
