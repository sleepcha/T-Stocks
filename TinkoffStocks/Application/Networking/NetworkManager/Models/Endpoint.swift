//
//  Endpoint.swift
//  T-Stocks
//
//  Created by sleepcha on 8/17/24.
//

import Foundation

// MARK: - Endpoint

protocol Endpoint {
    associatedtype Response: Decodable
    var path: URL { get }
}

// MARK: - POSTEndpoint

protocol POSTEndpoint: Endpoint {
    associatedtype Request: Encodable
    var request: Request { get }
}

// MARK: - API

/// A convenient namespace for endpoints.
enum API {
    struct POST<Request: Encodable, Response: Decodable>: POSTEndpoint {
        let path: URL
        let request: Request
    }
}
