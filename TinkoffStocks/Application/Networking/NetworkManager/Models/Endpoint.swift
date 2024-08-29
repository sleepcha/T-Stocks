//
//  Endpoint.swift
//  T-Stocks
//
//  Created by sleepcha on 8/17/24.
//

// MARK: - Endpoint

protocol Endpoint: HTTPRequest {
    associatedtype Request: Encodable
    associatedtype Response: Decodable
}

// MARK: - API

/// A convenient namespace for endpoints; to be extended with static instances of the `Endpoint` conforming type.
enum API {}
