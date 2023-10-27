//
//  CharacterCollectionController.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit
import Marvel

private enum Section: Hashable {
    case character
}

public protocol CharacterImageLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> ())
}

class CharacterCollectionController: UICollectionViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, CharacterItem>! = nil
    
    private var imageLoader: CharacterImageLoader?
    
    convenience init(imageLoader: CharacterImageLoader) {
        self.init()
        self.imageLoader = imageLoader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
    }
    
    func display(models: [CharacterItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CharacterItem>()
        snapshot.appendSections([.character])
        snapshot.appendItems(models)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension CharacterCollectionController {
    private func createLayout() -> UICollectionViewLayout {
        let size = view.frame.size
        if size.width > size.height {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(size.width / 5))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return UICollectionViewCompositionalLayout(section: section)
        } else {
            let adaptSize = size.width / 2
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(adaptSize), heightDimension: .absolute(adaptSize))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(adaptSize))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return UICollectionViewCompositionalLayout(section: section)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureHierarchy()
    }
}

extension CharacterCollectionController {
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<CharacterCollectionCell, CharacterItem>(cellNib: UINib(nibName: "CharacterCollectionCell", bundle: nil)) { [weak self] (cell, indexPath, item) in
            cell.retryButton.isHidden = true
            cell.characterImage.image = nil
            self?.imageLoader?.loadImageData(from: item.thumbnail, completion: { result in
                switch result {
                case let .success(data):
                    DispatchQueue.main.async {
                        cell.characterImage.image = UIImage(data: data)
                        cell.retryButton.isHidden = true
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        cell.retryButton.isHidden = false
                    }
                }
            })
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, CharacterItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: CharacterItem) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}
