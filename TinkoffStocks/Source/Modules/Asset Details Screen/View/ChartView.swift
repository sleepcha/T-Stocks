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
            let candle = viewModel.candles[$0]
            let state = candle.gainState

            if state == .neutral {
                RectangleMark(
                    x: .value("id", $0),
                    y: .value("open", candle.open),
                    width: 4,
                    height: 1
                )
                .foregroundStyle(state.foregroundColor)
            } else {
                RectangleMark(
                    x: .value("id", $0),
                    yStart: .value("open", candle.open),
                    yEnd: .value("close", candle.close),
                    width: 4
                )
                .foregroundStyle(state.foregroundColor)
            }

            RectangleMark(
                x: .value("id", $0),
                yStart: .value("high", candle.high),
                yEnd: .value("low", candle.low),
                width: 1
            )
            .foregroundStyle(state.foregroundColor)
        }
        .chartXAxis {
            AxisMarks(position: .top, values: viewModel.axisIndices) {
                if let index = $0.as(Int.self) {
                    AxisGridLine().foregroundStyle(.gray)
                    AxisValueLabel(orientation: .horizontal) {
                        Text(viewModel.candles[index].formattedDate)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: [viewModel.minY, viewModel.maxY]) { value in
                if let price = value.as(Decimal.self), viewModel.minY != viewModel.maxY {
                    AxisValueLabel {
                        Text(price.formatted()).padding(.bottom, 8)
                    }
                }
            }
            AxisMarks(values: [viewModel.closePrice]) { value in
                if let price = value.as(Decimal.self) {
                    AxisGridLine()
                    AxisValueLabel {
                        Text(price.formatted())
                    }
                }
            }
        }
        .chartXScale(domain: viewModel.minX...viewModel.maxX)
        .chartYScale(domain: viewModel.minY * 0.999...viewModel.maxY * 1.001)
        .frame(height: 333, alignment: .top)
    }
}
