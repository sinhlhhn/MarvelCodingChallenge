//
//  HTTPClient.swift
//  Marvel
//
//  Created by Sam on 26/10/2023.
//

import Foundation

public protocol HTTPClient {
    
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
