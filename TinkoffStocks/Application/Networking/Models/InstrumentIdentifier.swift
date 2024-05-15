//
//  InstrumentIdentifier.swift
//  TinkoffStocks
//
//  Created by sleepcha on 9/17/23.
//

import Foundation

enum InstrumentIdentifier {
    enum ClassCode: String {
        /// Currencies
        case cets
        /// ETFs
        case tqte, tqtd, tqif, tqtf
        /// Futures
        case spbfut
        /// Bonds
        case tqoy, spbbnd, tqcb, tqob, tqoe, psau, tqir, tqod
        /// Shares
        case tqbr, spbkz, tqpi, spbhkex, spbde, spbru
        /// ETFs and shares
        case spbxm
        /// Options
        case spbopt
    }

    case ticker(ClassCode, String)
    case figi(String)
    case uid(String)

    var request: InstrumentRequest {
        switch self {
        case let .ticker(classCode, ticker):
            InstrumentRequest(idType: .typeTicker, classCode: classCode.rawValue.uppercased(), id: ticker)
        case let .figi(figi):
            InstrumentRequest(idType: .typeFigi, id: figi)
        case let .uid(uid):
            InstrumentRequest(idType: .typeUid, id: uid)
        }
    }
}
