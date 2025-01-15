//
//  ChipsRow.swift
//  T-Stocks
//
//  Created by sleepcha on 1/11/25.
//

import SwiftUI

// MARK: - IntervalChips

struct IntervalChips: View {
    @Binding var selectedChip: CandleStickInterval
    var onChangeHandler: VoidHandler?
    private let chipItems: [CandleStickInterval] = CandleStickInterval.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(chipItems, id: \.self) { item in
                    ChipView(text: item.name, isSelected: selectedChip == item)
                        .onTapGesture {
                            selectedChip = item
                            onChangeHandler?()
                        }
                }
            }
            .padding(8)
        }
    }
}

// MARK: - ChipView

struct ChipView: View {
    let text: String
    let isSelected: Bool

    private var textColor: Color { isSelected ? .labelColor : .gray }
    private var bgColor: Color { isSelected ? .systemBackground : .clear }

    var body: some View {
        Text(text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(textColor)
            .background(
                Capsule()
                    .fill(isSelected ? .chipSelection : .systemBackground)
                    .background(
                        Capsule()
                            .stroke(.chipBorder.opacity(isSelected ? 1 : 0.55), lineWidth: 2)
                    )
            )
    }
}

// MARK: - Helpers

private extension CandleStickInterval {
    var name: String {
        switch self {
        case .min5: String(localized: "CandleStickInterval.min5", defaultValue: "М5")
        case .min15: String(localized: "CandleStickInterval.min15", defaultValue: "М15")
        case .min30: String(localized: "CandleStickInterval.min30", defaultValue: "М30")
        case .hour1: String(localized: "CandleStickInterval.hour1", defaultValue: "Ч1")
        case .hour4: String(localized: "CandleStickInterval.hour4", defaultValue: "Ч4")
        case .day: String(localized: "CandleStickInterval.day", defaultValue: "День")
        case .week: String(localized: "CandleStickInterval.week", defaultValue: "Неделя")
        case .month: String(localized: "CandleStickInterval.month", defaultValue: "Месяц")
        }
    }
}
