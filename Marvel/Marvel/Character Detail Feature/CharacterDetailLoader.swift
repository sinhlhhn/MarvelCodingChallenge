//
//  CharacterDetailLoader.swift
//  Marvel
//
//  Created by Sam on 29/10/2023.
//

import Foundation

public protocol CharacterDetailLoader {
    func load(from url: URL, completion: @escaping ((Result<CharacterDetailItem, Error>) -> Void))
}
