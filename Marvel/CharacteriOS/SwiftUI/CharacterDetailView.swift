//
//  CharacterDetailView.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import SwiftUI
import Marvel

public struct CharacterDetailView: View {
    
    @ObservedObject var viewModel: CharacterDetailViewModel
    
    public init(viewModel: CharacterDetailViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .success(item):
                List {
                    Section {
                        HeaderCharacterDetailCell(item: item)
                    }
                    
                    Section {
                        ForEach(item.comicNames, id: \.self) { name in
                            CharacterDetailCell(comic: name)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            case let .failure(error):
                Text(error).lineLimit(0)
            }
        }.onAppear {
            viewModel.loadData()
        }
    }
}

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
            DispatchQueue.main.async {
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
}

struct CharacterDetailCell: View {
    let comic: String
    var body: some View {
        Text(comic)
    }
}
