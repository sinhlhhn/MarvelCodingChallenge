//
//  Composer.swift
//  MarvelApp
//
//  Created by Sam on 27/10/2023.
//

import Foundation
import Marvel
import CharacteriOS
import SwiftUI

public class CharacterUIComposer {
    public static func characterComposeWith(characterLoader: CharacterLoader, imageLoader: CharacterImageDataLoader, onSelect: @escaping (CharacterItem) -> Void) -> CharacterCollectionController {
        let refreshController = CharacterRefreshViewController(characterLoader: characterLoader)
        let characterVC = CharacterCollectionController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak characterVC] items in
            let cellControllers = items.map { item in
                CharacterImageCellController(id: item, imageLoader: imageLoader, item: item, onSelect: {
                    onSelect(item)
                })
            }
            characterVC?.display(items: cellControllers)
        }
        
        refreshController.onError = { [weak characterVC] error in
            characterVC?.display(error: error)
        }
        
        return characterVC
    }
    
    public static func characterDetailComposeWith(url: URL, client: HTTPClient) -> UIHostingController<CharacterDetailView> {
        let vm = CharacterDetailViewModel(url: url, client: client)
        let view = CharacterDetailView(viewModel: vm)
        
        return UIHostingController(rootView: view)
    }
}
