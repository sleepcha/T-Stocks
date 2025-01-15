//
//  AssetDetailsAssembly.swift
//  T-Stocks
//
//  Created by sleepcha on 11/20/24.
//

import SwiftUI
import UIKit

// MARK: - AssetDetailsScreenAssembly

protocol AssetDetailsScreenAssembly {
    func build(
        asset: Asset,
        candlesRepository: CandlesRepository,
        portfolioDataRepository: PortfolioDataRepository,
        outputHandler: @escaping Handler<AssetDetailsScreenOutput>
    ) -> UIViewController
}

// MARK: - AssetDetailsScreenAssemblyImpl

final class AssetDetailsScreenAssemblyImpl: AssetDetailsScreenAssembly {
    func build(
        asset: Asset,
        candlesRepository: CandlesRepository,
        portfolioDataRepository: PortfolioDataRepository,
        outputHandler: @escaping Handler<AssetDetailsScreenOutput>
    ) -> UIViewController {
        let vm = AssetDetailsViewModelImpl(
            chartViewModel: ChartViewModelImpl(),
            asset: asset,
            candlesRepository: candlesRepository,
            portfolioDataRepository: portfolioDataRepository,
            outputHandler: outputHandler
        )
        let view = AssetDetailsView<AssetDetailsViewModelImpl>(viewModel: vm)
        let vc = UIHostingController(rootView: view)

        let appearance = UINavigationBarAppearance().configuring {
            $0.configureWithOpaqueBackground()
            $0.backgroundColor = UIColor(hex: asset.brand.bgColor)
        }

        vc.navigationItem.standardAppearance = appearance
        vc.navigationItem.scrollEdgeAppearance = appearance
        vc.hidesBottomBarWhenPushed = true
        vc.navigationItem.titleView = UIStackView(
            views: [
                UILabel.makeLabel(asset.name, style: .headline, textColor: UIColor(hex: asset.brand.textColor)),
                UILabel.makeLabel(asset.ticker, style: .footnote, textColor: UIColor(hex: asset.brand.textColor)),
            ],
            axis: .vertical,
            alignment: .center
        )

        return vc
    }
}

private extension UILabel {
    static func makeLabel(_ text: String, style: UIFont.TextStyle, textColor: UIColor?) -> UILabel {
        UILabel {
            $0.text = text
            $0.textColor = textColor
            $0.font = UIFont.preferredFont(forTextStyle: style)
            $0.textAlignment = .center
        }
    }
}
