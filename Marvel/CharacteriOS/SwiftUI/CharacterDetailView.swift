//
//  CharacterDetailView.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import SwiftUI

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
