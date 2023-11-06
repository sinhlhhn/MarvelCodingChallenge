//
//  XCTestCase+CharacterCollectionController.swift
//  CharacterUIIntegrationTests
//
//  Created by Sam on 06/11/2023.
//

import CharacteriOS
import UIKit

extension CharacterCollectionController {
    func simulateUserInitiatedCharacterReload() {
        collectionView.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
    
    private var characterImageSection: Int { 0 }
    
    func numberOfRenderedCharacterImageViews() -> Int {
        numberOfRow(in: characterImageSection)
    }
    
    func numberOfRow(in section: Int) -> Int {
        collectionView.numberOfSections > section ? collectionView.numberOfItems(inSection: section) : 0
    }
    
    func characterImageView(at row: Int) -> UICollectionViewCell? {
        cell(row: row, section: characterImageSection)
    }
    
    func cell(row: Int, section: Int) -> UICollectionViewCell? {
        guard numberOfRow(in: section) > row else {
            return nil
        }
        let ds = collectionView.dataSource
        let index = IndexPath(row: row, section: section)
        
        return ds?.collectionView(collectionView, cellForItemAt: index)
    }
    
    @discardableResult
    func simulateCharacterImageViewVisible(at row: Int) -> CharacterCollectionCell? {
        return characterImageView(at: row) as? CharacterCollectionCell
    }
    
    @discardableResult
    func simulateCharacterImageViewNotVisible(at row: Int) -> CharacterCollectionCell? {
        let view = simulateCharacterImageViewVisible(at: row)
        
        let delegate = collectionView.delegate
        let index = IndexPath(row: row, section: characterImageSection)
        delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: index)
        
        return view
    }
}
