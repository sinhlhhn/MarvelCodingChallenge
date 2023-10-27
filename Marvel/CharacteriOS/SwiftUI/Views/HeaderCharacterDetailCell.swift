//
//  HeaderCharacterDetailCell.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import SwiftUI
import Marvel

struct HeaderCharacterDetailCell: View {
    let item: CharacterDetailItem
    
    var body: some View {
        VStack {
            AsyncImage(url: item.thumbnail) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                case .failure:
                    Text("No Image")
                @unknown default:
                    EmptyView()
                }
            }
            Text(item.name)
        }
        .listRowBackground(Color.clear)
    }
}
