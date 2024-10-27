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

    let pageControl = UIPageControl {
        $0.isUserInteractionEnabled = false
    }

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

    private lazy var stack = UIStackView(
        views: [accountsCollectionView, pageControl],
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 0
    )

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
        addSubview(stack)
        addSubview(spinner)
    }

    func setupConstraints() {
        pageControl.snp.makeConstraints { $0.height.equalTo(C.UI.pageControlHeight) }

        stack.snp.makeConstraints { make in
            make.top.directionalHorizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(C.UI.doubleSpacing)
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
    static let pageControlHeight: CGFloat = 26
}
