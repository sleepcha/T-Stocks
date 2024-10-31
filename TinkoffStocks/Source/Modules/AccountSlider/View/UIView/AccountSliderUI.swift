//
//  AccountSliderUI.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import UIKit

// MARK: - AccountSliderUI

final class AccountSliderUI: UIView {
    lazy var accountsCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout
    ).configuring {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.contentInsetAdjustmentBehavior = .never
        $0.register(AccountCell.self)
    }

    let pageIndicator = PageIndicatorView()

    let spinner = UIActivityIndicatorView {
        $0.hidesWhenStopped = true
        $0.color = .white
        $0.style = .large
        $0.startAnimating()
    }

    private lazy var flowLayout = UICollectionViewFlowLayout {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        frame.size.height = C.UI.viewHeight
        addSubview(accountsCollectionView)
        addSubview(pageIndicator)
        addSubview(spinner)
    }

    private func setupConstraints() {
        accountsCollectionView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }

        pageIndicator.snp.makeConstraints { make in
            make.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide).inset(C.UI.doubleSpacing)
            make.top.equalTo(snp.bottom).inset(C.UI.doubleSpacing * 2)
        }

        spinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-C.UI.doubleSpacing)
        }
    }
}

// MARK: - Constants

private extension C.UI {
    static let viewHeight: CGFloat = 200
}
