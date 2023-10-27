//
//  CharacterCollectionCell.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit

class CharacterCollectionCell: UICollectionViewCell {

    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterImageContainerView: UIView!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet public var retryButton: UIButton!
    
    var onRetry: (() -> ())?
    var onReuse: (() -> ())?
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        onReuse?()
    }
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
