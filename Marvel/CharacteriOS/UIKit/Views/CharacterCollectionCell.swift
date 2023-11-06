//
//  CharacterCollectionCell.swift
//  CharacteriOS
//
//  Created by Sam on 27/10/2023.
//

import UIKit

public class CharacterCollectionCell: UICollectionViewCell {

    @IBOutlet public weak var characterNameLabel: UILabel!
    @IBOutlet public weak var characterImageContainerView: UIView!
    @IBOutlet public weak var characterImage: UIImageView!
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
