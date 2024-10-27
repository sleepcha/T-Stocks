//
//  PortfolioErrorView.swift
//  T-Stocks
//
//  Created by sleepcha on 10/27/24.
//

import UIKit

// MARK: - PortfolioErrorView

final class PortfolioErrorView: UIView {
    private let errorMessageLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .subheadline)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.adjustsFontForContentSizeCategory = true
        $0.numberOfLines = 0
    }

    private let refreshButton = LoadingButton {
        $0.setTitle(C.UI.refreshButtonTitle, for: .normal)
        $0.tintColor = .brandAccent
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black.withAlphaComponent(0.5), for: .highlighted)
    }

    private lazy var stack = UIStackView(
        views: [errorMessageLabel, refreshButton],
        axis: .vertical,
        alignment: .center,
        distribution: .equalSpacing,
        spacing: C.UI.doubleSpacing * 2
    )

    private var onRefreshButtonTap: VoidHandler?

    init(errorMessage: String, onRefreshButtonTap: @escaping VoidHandler) {
        super.init(frame: .zero)

        self.onRefreshButtonTap = onRefreshButtonTap
        errorMessageLabel.text = errorMessage
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .systemBackground
        addSubview(stack)
        refreshButton.addTarget(self, action: #selector(refreshButtonDidTap), for: .touchUpInside)
    }

    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(C.UI.doubleSpacing * 2)
        }
    }

    @objc private func refreshButtonDidTap() {
        onRefreshButtonTap?()
        refreshButton.isLoading = true
    }
}

// MARK: - Constants

private extension C.UI {
    static let refreshButtonTitle = String(localized: "PortfolioErrorView.refreshButtonTitle", defaultValue: "Обновить")
    static let refreshButtonWidth: CGFloat = 120
    static let refreshButtonHeight: CGFloat = 44
}
