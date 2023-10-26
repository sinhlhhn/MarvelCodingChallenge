//
//  HTTPClient.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public protocol HTTPClient {
    func get(url: URL, completion: @escaping ((Result<(Data, HTTPURLResponse), Error>) -> Void))
}
