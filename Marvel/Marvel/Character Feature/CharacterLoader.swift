//
//  CharacterLoader.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public protocol CharacterLoader {
    func load(from url: URL, completion: @escaping ((Result<[CharacterItem], Error>) -> Void))
}
