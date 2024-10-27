//
//  PortfolioSummaryView.swift
//  T-Stocks
//
//  Created by sleepcha on 10/27/24.
//

import UIKit

// MARK: - PortfolioSummaryView

final class PortfolioSummaryView: UIView {
    lazy var contentView = UIStackView(
        views: [valueLabel, gainLabel],
        axis: .vertical,
        alignment: .center,
        distribution: .equalSpacing,
        spacing: 0
    )

    private let valueLabel = UILabel {
        $0.textColor = .white
        $0.font = .preferredFont(forTextStyle: .headline)
    }

    private let gainLabel = UILabel {
        $0.textColor = .white
        $0.font = .preferredFont(forTextStyle: .footnote)
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with summary: PortfolioSummary?) {
        valueLabel.text = summary?.total ?? nil
        gainLabel.attributedText = summary?.gain ?? nil
    }

    private func setupViews() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }
    }
}
