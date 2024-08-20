//
//  Endpoint.swift
//  T-Stocks
//
//  Created by sleepcha on 8/17/24.
//

protocol Endpoint: HTTPRequest {
    associatedtype Request: Encodable
    associatedtype Response: Decodable
}
