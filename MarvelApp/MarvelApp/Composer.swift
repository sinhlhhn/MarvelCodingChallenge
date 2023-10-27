//
//  Composer.swift
//  MarvelApp
//
//  Created by Sam on 27/10/2023.
//

import Foundation
import Marvel
import CharacteriOS

public class CharacterUIComposer {
    public static func characterComposeWith(characterLoader: CharacterLoader, imageLoader: CharacterImageDataLoader) -> CharacterCollectionController {
        let refreshController = CharacterRefreshViewController(characterLoader: characterLoader)
        let characterVC = CharacterCollectionController(refreshController: refreshController)
        
        refreshController.onRefresh = { [weak characterVC] items in
            let cellControllers = items.map { item in
                CharacterImageCellController(id: item, imageLoader: imageLoader, item: item)
            }
            characterVC?.display(items: cellControllers)
        }
        
        refreshController.onError = { [weak characterVC] error in
            characterVC?.display(error: error)
        }
        
        return characterVC
    }
}
