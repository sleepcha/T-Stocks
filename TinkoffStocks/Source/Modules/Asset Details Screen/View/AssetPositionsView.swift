//
//  AssetPositionsView.swift
//  T-Stocks
//
//  Created by sleepcha on 1/13/25.
//

import SwiftUI

// MARK: - AssetPositionsView

struct AssetPositionsView: View {
    var positions: [AssetPositionModel]

    var body: some View {
        LazyVStack(alignment: .leading) {
            if !positions.isEmpty {
                Text("В портфеле").font(.title3).bold()
            }
            ForEach(positions, id: \.id) {
                PositionView(assetPositionModel: $0)
            }
            .padding(.vertical, 6)
        }
    }
}

// MARK: - PositionView

struct PositionView: View {
    let assetPositionModel: AssetPositionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(assetPositionModel.accountName)
                .textCase(.uppercase)
                .font(.footnote)
                .foregroundStyle(Color.secondaryLabel)

            Text(assetPositionModel.quantity).font(.headline)

            Text(assetPositionModel.priceChange)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryLabel)

            Divider().padding(.vertical, 4)

            Text("Стоимость бумаг в портфеле")
                .textCase(.uppercase)
                .font(.footnote)
                .foregroundStyle(Color.secondaryLabel)

            Text(assetPositionModel.value).font(.headline)

            Text(assetPositionModel.gain)
                .font(.subheadline)
                .foregroundStyle(assetPositionModel.gainState.foregroundColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.assetPositionBackground)
        )
    }
}

// MARK: - Constants

private extension Color {
    static let secondaryLabel = Color.secondary.opacity(0.8)
}

#Preview {
    AssetPositionsView(
        positions: ([
            AssetPositionModel(
                accountName: "Брокерский счёт",
                quantity: "390 шт",
                priceChange: "645,11 → 673,36",
                value: "267 009,6 ₽",
                gain: "↑11 017,5 ₽ · 4,38 %",
                gainState: GainState.profit
            ),
            AssetPositionModel(
                accountName: "ИИС",
                quantity: "310 шт",
                priceChange: "704,36 → 673,36",
                value: "212 238,4 ₽",
                gain: "↓9 610 ₽ · 4,4 %",
                gainState: GainState.loss
            ),
        ])
    )
}
