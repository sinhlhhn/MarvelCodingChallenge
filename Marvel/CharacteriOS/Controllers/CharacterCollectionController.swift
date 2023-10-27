//
//  CharacterCollectionController.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit
import Marvel

public class CharacterCollectionController: UICollectionViewController {
    
    private enum Section: Hashable {
        case character
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, CharacterImageCellController>?
    
    private var refreshController: CharacterRefreshViewController?
    private var tasks: [IndexPath: CharacterImageCellController] = [:]
    
    public convenience init(refreshController: CharacterRefreshViewController) {
        self.init(collectionViewLayout: .init())
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        
        collectionView.refreshControl = refreshController?.view
        refreshController?.refresh()
    }
    
    public func display(items: [CharacterImageCellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CharacterImageCellController>()
        snapshot.appendSections([.character])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancelRequest()
    }
}

extension CharacterCollectionController {
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CharacterCollectionCell, CharacterImageCellController>(cellNib: UINib(nibName: "CharacterCollectionCell", bundle: Bundle(for: CharacterCollectionCell.self))) { [weak self] (cell, indexPath, controller) in
            self?.tasks[indexPath] = controller
            controller.configure(cell: cell)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, CharacterImageCellController>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: CharacterImageCellController) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            return cell
        }
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
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configureHierarchy()
    }
}
