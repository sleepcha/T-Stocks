//
//  ChartView.swift
//  T-Stocks
//
//  Created by sleepcha on 1/11/25.
//

import Charts
import SwiftUI

struct ChartView<ViewModel: ChartViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Chart(viewModel.candles.indices, id: \.self) {
            CandleChartContent(id: $0, candle: viewModel.candles[$0])
        }
        .chartXAxis {
            AxisMarks(position: .top, values: viewModel.axisIndices) {
                if let index = $0.as(Int.self), let dateString = viewModel.candles[safe: index]?.formattedDate {
                    AxisGridLine().foregroundStyle(.gray)
                    AxisValueLabel(orientation: .horizontal) {
                        Text(dateString)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: [viewModel.rangeY.lowerBound, viewModel.rangeY.upperBound]) { value in
                if let price = value.as(Decimal.self) {
                    AxisValueLabel {
                        Text(price.formatted())
                    }
                }
            }
            AxisMarks(values: [viewModel.closePrice]) { value in
                if let price = value.as(Decimal.self) {
                    AxisGridLine()
                    AxisValueLabel {
                        Text(price.formatted()).background()
                    }
                }
            }
        }
        .chartXScale(domain: viewModel.rangeX)
        .chartYScale(domain: viewModel.rangeY, range: .plotDimension(padding: 16))
        .frame(height: 333, alignment: .top)
    }

    struct CandleChartContent: ChartContent {
        let id: Int
        let candle: CandleStickModel

        var body: some ChartContent {
            let priceChange = candle.priceChange()

            if priceChange.outcome == .neutral {
                RectangleMark(
                    x: .value("id", id),
                    y: .value("open", candle.open),
                    width: 4,
                    height: 1
                )
                .foregroundStyle(priceChange.foregroundColor)
            } else {
                RectangleMark(
                    x: .value("id", id),
                    yStart: .value("open", candle.open),
                    yEnd: .value("close", candle.close),
                    width: 4
                )
                .foregroundStyle(priceChange.foregroundColor)
            }

            RectangleMark(
                x: .value("id", id),
                yStart: .value("high", candle.high),
                yEnd: .value("low", candle.low),
                width: 1
            )
            .foregroundStyle(priceChange.foregroundColor)
        }
    }
}
