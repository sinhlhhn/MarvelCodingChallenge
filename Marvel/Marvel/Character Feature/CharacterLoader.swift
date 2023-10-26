//
//  CharacterLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

protocol CharacterLoader {
    func load(completion: @escaping ((Result<CharacterItem, Error>) -> Void))
}
