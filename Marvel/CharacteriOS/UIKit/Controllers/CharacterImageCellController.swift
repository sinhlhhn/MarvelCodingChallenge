//
//  CharacterImageCellController.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit
import Marvel

public class CharacterImageCellController {
    private let id: AnyHashable
    private let imageLoader: CharacterImageDataLoader
    
    private var task: CharacterImageDataLoaderTask?
    private let item: CharacterItem
    
    private let onSelect: () -> Void
    
    public init(id: AnyHashable, imageLoader: CharacterImageDataLoader, item: CharacterItem, onSelect: @escaping () -> Void) {
        self.id = id
        self.imageLoader = imageLoader
        self.item = item
        self.onSelect = onSelect
    }
    
    func configure(cell: CharacterCollectionCell) {
        cell.retryButton.isHidden = true
        cell.characterImage.image = nil
        cell.characterImageContainerView.isShimmering = true
        cell.characterNameLabel.text = item.name
        let loadImage = { [weak self] in
            guard let self = self else { return }
            self.task = self.imageLoader.loadImageData(from: item.thumbnail, completion: { [cell] result in
                switch result {
                case let .success(data):
                    
                    cell.characterImage.image = UIImage(data: data)
                    cell.retryButton.isHidden = true
                    
                case .failure(_):
                    cell.retryButton.isHidden = false
                }
                cell.characterImageContainerView.isShimmering = false
            })
        }
        
        cell.onRetry = loadImage
        
        cell.onReuse = { [weak self] in
            self?.cancelRequest()
        }
        
        loadImage()
    }
    
    func cancelRequest() {
        task?.cancel()
        task = nil
    }
    
    func selectItem() {
        onSelect()
    }
    
}

extension CharacterImageCellController: Equatable {
    public static func == (lhs: CharacterImageCellController, rhs: CharacterImageCellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CharacterImageCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
