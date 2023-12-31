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
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .red
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16)
        ])
        
        return label
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, CharacterImageCellController>?
    
    private var refreshController: CharacterRefreshViewController?
    private var loadMoreController: CharacterLoadMoreViewController?
    
    public convenience init(refreshController: CharacterRefreshViewController, loadMoreController: CharacterLoadMoreViewController) {
        self.init(collectionViewLayout: .init())
        self.refreshController = refreshController
        self.loadMoreController = loadMoreController
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
    
    public func displayNewItems(items: [CharacterImageCellController]) {
        guard let dataSource = dataSource else { return }
        var snapshot = dataSource.snapshot(for: Section.character)
        snapshot.append(items)
        dataSource.apply(snapshot, to: Section.character)
    }
    
    public func display(error: String?) {
        errorLabel.isHidden = error == nil
        errorLabel.text = error
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        dataSource?.itemIdentifier(for: indexPath)?.cancelRequest()
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource?.itemIdentifier(for: indexPath) else { return }
        selectedItem.selectItem()
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging, let dataSource = dataSource, !dataSource.snapshot().itemIdentifiers.isEmpty else { return }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if (offsetY > contentHeight - scrollView.frame.height) {
            loadMoreController?.loadMore(page: dataSource.snapshot(for: Section.character).items.count)
        }
    }
}

extension CharacterCollectionController {
    private func configureHierarchy() {
        collectionView.collectionViewLayout = createLayout()
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<CharacterCollectionCell, CharacterImageCellController>(cellNib: UINib(nibName: "CharacterCollectionCell", bundle: Bundle(for: CharacterCollectionCell.self))) { (cell, indexPath, controller) in
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
