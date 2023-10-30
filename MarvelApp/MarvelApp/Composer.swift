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
    
    public static func characterComposeWith(with baseURL: URL, characterLoader: CharacterLoader, imageLoader: CharacterImageDataLoader, onSelect: @escaping (CharacterItem) -> Void) -> CharacterCollectionController {
        let url = CharacterEndpoint.get(0).url(baseURL: baseURL)
        let refreshController = CharacterRefreshViewController(url: url, characterLoader: characterLoader)
        let loadMoreController = CharacterLoadMoreViewController(characterLoader: characterLoader)
        let characterVC = CharacterCollectionController(refreshController: refreshController, loadMoreController: loadMoreController)
        
        refreshController.onRefresh = { [weak characterVC] items in
            let cellControllers = items.characters.map { item in
                CharacterImageCellController(id: item, imageLoader: imageLoader, item: item, onSelect: {
                    onSelect(item)
                })
            }
            characterVC?.display(items: cellControllers)
        }
        
        loadMoreController.onRefresh = { [weak characterVC] items in
            let cellControllers = items.characters.map { item in
                CharacterImageCellController(id: item, imageLoader: imageLoader, item: item, onSelect: {
                    onSelect(item)
                })
            }
            characterVC?.displayNewItems(items: cellControllers)
        }
        
        loadMoreController.onLoadMore = { page in
            let nextURL = CharacterEndpoint.get(page).url(baseURL: baseURL)
            loadMoreController.loadMore(url: nextURL)
        }
        
        refreshController.onError = { [weak characterVC] error in
            characterVC?.display(error: error)
        }
        
        loadMoreController.onError = { [weak characterVC] error in
            characterVC?.display(error: error)
        }
        
        return characterVC
    }
    
    public static func characterDetailComposeWith(url: URL, loader: CharacterDetailLoader) -> UIHostingController<CharacterDetailView> {
        let vm = CharacterDetailViewModel(url: url, loader: loader)
        let view = CharacterDetailView(viewModel: vm)
        
        return UIHostingController(rootView: view)
    }
}

extension RemoteLoader: CharacterLoader where Item == Paginated {}
extension RemoteLoader: CharacterDetailLoader where Item == CharacterDetailItem {}
