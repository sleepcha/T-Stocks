//
//  AssetDetailsView.swift
//  T-Stocks
//
//  Created by sleepcha on 11/1/24.
//

import SwiftUI

// MARK: - AssetDetailsView

struct AssetDetailsView<ViewModel: AssetDetailsViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    // MARK: - Body

    var body: some View {
        switch viewModel.state {
        case .idle:
            ZStack(alignment: .bottom) {
                mainList
                buttonStack
            }
        case .showingError(let message):
            ErrorView(errorMessage: message) {
                await viewModel.reload()
            }
        }
    }

    // MARK: Subviews

    private var mainList: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text(viewModel.currentPrice).font(.title).bold()
                    Text(viewModel.priceChange.formattedProfit)
                        .font(.footnote)
                        .foregroundStyle(viewModel.priceChange.foregroundColor)
                }
            }
            .listRowSeparator(.hidden)
            .padding(.vertical)

            Section {
                ChartView(viewModel: viewModel.chartViewModel)
                    .listRowSeparator(.visible)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                    .alignmentGuide(.listRowSeparatorLeading, computeValue: { _ in 0 })

                IntervalChips(selectedChip: $viewModel.selectedInterval)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 16, trailing: 0))
            }

            Section {
                AssetPositionsView(positions: viewModel.openPositions).padding(.bottom, 80)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .task {
            await viewModel.reload()
        }
        .refreshable {
            await viewModel.reload()
        }
    }

    private var buttonStack: some View {
        HStack(alignment: .center) {
            Button("Продать") {
                viewModel.sellButtonTapped()
            }
            .buttonStyle(RoundedButtonStyle(backgroundColor: .sellButton, foregroundColor: .systemBackground))

            Button("Купить") {
                viewModel.buyButtonTapped()
            }
            .buttonStyle(RoundedButtonStyle(backgroundColor: .buyButton, foregroundColor: .white))
        }
        .padding()
    }

    // MARK: Styles

    private struct RoundedButtonStyle: ButtonStyle {
        var backgroundColor: Color
        var foregroundColor: Color

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(backgroundColor)
                .foregroundStyle(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
    }
}

// MARK: - Helpers

extension PriceChange {
    var foregroundColor: Color {
        switch outcome {
        case .profit: .profit
        case .loss: .loss
        case .neutral: .brandLabel
        }
    }
}

// MARK: - Constants

extension Color {
    static let systemBackground: Color = Color(.systemBackground)
    static let labelColor: Color = Color(.label)
}
