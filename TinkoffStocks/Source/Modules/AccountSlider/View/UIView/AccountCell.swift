//
//  AccountCell.swift
//  T-Stocks
//
//  Created by sleepcha on 9/10/24.
//

import UIKit

// MARK: - AccountCellModel

struct AccountCellModel {
    let id: String
    let name: String
    let value: String
    let gain: NSAttributedString
    let gainPeriodButtonTitle: String
}

// MARK: - AccountCell

final class AccountCell: UICollectionViewCell {
    var gainPeriodButtonTapHandler: VoidHandler?

    private let nameLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .title2).withTraits(.traitBold)
        $0.textColor = .white
        $0.adjustsFontForContentSizeCategory = true
    }

    private let valueLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .largeTitle).withTraits(.traitBold)
        $0.textColor = .white
        $0.adjustsFontForContentSizeCategory = true
    }

    private let gainLabel = RoundedLabel {
        $0.font = .preferredFont(forTextStyle: .footnote).withTraits(.traitBold)
        $0.lineBreakMode = .byTruncatingHead
        $0.layer.cornerRadius = $0.bounds.height / 2
        $0.adjustsFontForContentSizeCategory = true
    }

    private let gainPeriodButton = UIButton {
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setTitleColor(.white, for: .highlighted)
        $0.titleLabel?.font = .preferredFont(forTextStyle: .footnote).withTraits(.traitBold)
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }

    private lazy var gainStack = UIStackView(
        views: [gainLabel, gainPeriodButton],
        axis: .horizontal,
        alignment: .center,
        distribution: .equalSpacing,
        spacing: C.UI.spacing
    )

    private lazy var verticalStack = UIStackView(
        views: [nameLabel, valueLabel, gainStack],
        axis: .vertical,
        alignment: .leading,
        distribution: .equalSpacing,
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

    override func prepareForReuse() {
        super.prepareForReuse()
        valueLabel.text = nil
        gainLabel.text = nil
        valueLabel.layer.removeAllAnimations()
        gainStack.layer.removeAllAnimations()
    }

    func configure(with account: AccountCellModel) {
        nameLabel.text = account.name
        valueLabel.text = account.value
        gainLabel.attributedText = account.gain
        gainLabel.backgroundColor = gainLabel.textColor.bgColor
        gainPeriodButton.setTitle(account.gainPeriodButtonTitle, for: .normal)
    }

    @objc private func didTapGainPeriodButton(sender: UIButton) {
        gainPeriodButtonTapHandler?()
    }

    private func setupViews() {
        backgroundColor = .clear
        contentView.addSubview(verticalStack)
        gainPeriodButton.addTarget(self, action: #selector(didTapGainPeriodButton), for: .touchUpInside)
    }

    private func setupConstraints() {
        verticalStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(C.UI.doubleSpacing * 2)
            make.height.equalTo(C.UI.cellHeight)
        }
        gainLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        gainPeriodButton.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
    }
}

// MARK: - Helpers

private extension UIColor {
    var bgColor: UIColor {
        withRelativeBrightness(0.6).withAlphaComponent(0.33)
    }
}

// MARK: - Constants

private extension C.UI {
    static let animationDuration: TimeInterval = 3.333
    static let cellHeight: CGFloat = 120
}
