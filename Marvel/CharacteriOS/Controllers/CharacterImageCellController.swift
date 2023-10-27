//
//  CharacterImageCellController.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit
import Marvel

public class CharacterImageCellController {
    private let imageLoader: CharacterImageDataLoader
    
    private var task: CharacterImageDataLoaderTask?
    private let cell: CharacterCollectionCell
    private let item: CharacterItem
    
    init(imageLoader: CharacterImageDataLoader, cell: CharacterCollectionCell, item: CharacterItem) {
        self.imageLoader = imageLoader
        self.cell = cell
        self.item = item
    }
    
    func configureCell(at indexPath: IndexPath) {
        cell.retryButton.isHidden = true
        cell.characterImage.image = nil
        cell.characterImageContainerView.isShimmering = true
        cell.characterNameLabel.text = item.name
        let loadImage = { [weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: item.thumbnail, completion: { [cell] result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(data):
                        
                        cell.characterImage.image = UIImage(data: data)
                        cell.retryButton.isHidden = true
                        
                    case .failure(_):
                        cell.retryButton.isHidden = false
                    }
                    cell.characterImageContainerView.isShimmering = false
                }
            })
        }
        
        cell.onRetry = loadImage
        
        loadImage()
    }
    
    deinit {
        task?.cancel()
    }
}
