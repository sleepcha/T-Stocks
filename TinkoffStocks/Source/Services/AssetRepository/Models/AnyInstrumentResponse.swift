//
//  AnyInstrumentResponse.swift
//  T-Stocks
//
//  Created by sleepcha on 7/27/24.
//

// MARK: - AnyInstrumentResponse

protocol AnyInstrumentResponse {
    associatedtype T: AnyInstrument
    var instrument: T { get }
}

extension InstrumentResponse: AnyInstrumentResponse {}
extension ShareResponse: AnyInstrumentResponse {}
extension BondResponse: AnyInstrumentResponse {}
extension EtfResponse: AnyInstrumentResponse {}
extension FutureResponse: AnyInstrumentResponse {}
extension OptionResponse: AnyInstrumentResponse {}
extension CurrencyResponse: AnyInstrumentResponse {}
