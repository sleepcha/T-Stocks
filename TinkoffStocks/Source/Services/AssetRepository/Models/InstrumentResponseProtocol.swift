//
//  InstrumentResponseProtocol.swift
//  T-Stocks
//
//  Created by sleepcha on 7/27/24.
//

// MARK: - InstrumentResponseProtocol

protocol InstrumentResponseProtocol {
    associatedtype T: InstrumentProtocol
    var instrument: T { get }
}

extension InstrumentResponse: InstrumentResponseProtocol {}
extension ShareResponse: InstrumentResponseProtocol {}
extension BondResponse: InstrumentResponseProtocol {}
extension EtfResponse: InstrumentResponseProtocol {}
extension FutureResponse: InstrumentResponseProtocol {}
extension OptionResponse: InstrumentResponseProtocol {}
extension CurrencyResponse: InstrumentResponseProtocol {}
