//
//  PortfolioData.swift
//  T-Stocks
//
//  Created by sleepcha on 10/23/24.
//

import Foundation

// MARK: - PortfolioData

struct PortfolioData {
    struct OpenPosition {
        let instrumentID: String
        let instrumentType: String
        let quantity: Decimal
        let currentPrice: Decimal
        let averagePrice: Decimal
        let isBlockedInstrument: Bool
    }

    let id: String
    let name: String
    let totalValue: Decimal
    let openPositions: [OpenPosition]
}

// MARK: - Model mapping

extension PortfolioData {
    init(from response: PortfolioResponse, accountName: String) {
        self.id = response.accountId
        self.name = accountName
        self.totalValue = response.totalAmountPortfolio.asDecimal ?? 0
        self.openPositions = response.positions.map {
            OpenPosition(
                instrumentID: $0.instrumentUid,
                instrumentType: $0.instrumentType,
                quantity: $0.quantity.asDecimal ?? 0,
                currentPrice: $0.currentPrice?.asDecimal ?? 0,
                averagePrice: $0.averagePositionPriceFifo?.asDecimal ?? 0,
                isBlockedInstrument: $0.blocked
            )
        }
    }
}
