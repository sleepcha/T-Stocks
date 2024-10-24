//
//  PortfolioItemCell.swift
//  T-Stocks
//
//  Created by sleepcha on 9/9/24.
//

import UIKit

// MARK: - PortfolioItemCellModel

struct PortfolioItemCellModel {
    let id: String
    let ticker: String
    let name: String
    let quantity: String
    let value: String
    let gain: NSAttributedString
    let priceChange: String
    let backgroundColor: String
    let textColor: String
}

// MARK: - PortfolioItemCell

final class PortfolioItemCell: UITableViewCell {
    private let logoImageView = RoundedImageView {
        $0.contentMode = .scaleAspectFit
        $0.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor
        $0.cornerRadiusRatio = C.UI.logoCornerRadiusRatio
    }

    private let tickerLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .brandLabel
        $0.textAlignment = .left
    }

    private let nameLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textColor = .brandLabel
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingMiddle
    }

    private let priceChangeLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .left
        $0.lineBreakMode = .byTruncatingHead
    }

    private let valueLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.textColor = .brandLabel
        $0.textAlignment = .right
    }

    private let quantityLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .right
    }

    private let gainLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.textAlignment = .right
    }

    private lazy var detailsStack = {
        let horizontalStacks = [
            UIStackView(
                views: [tickerLabel, valueLabel],
                axis: .horizontal,
                alignment: .center,
                distribution: .equalSpacing,
                spacing: C.UI.spacing
            ),
            UIStackView(
                views: [nameLabel, quantityLabel],
                axis: .horizontal,
                alignment: .center,
                distribution: .equalSpacing,
                spacing: C.UI.spacing
            ),
            UIStackView(
                views: [priceChangeLabel, gainLabel],
                axis: .horizontal,
                alignment: .center,
                distribution: .equalSpacing,
                spacing: C.UI.spacing
            ),
        ]

        return UIStackView(
            views: horizontalStacks,
            axis: .vertical,
            distribution: .fillEqually,
            spacing: C.UI.verticalSpacing
        )
    }()

    private lazy var mainStack = UIStackView(
        views: [logoImageView, detailsStack],
        axis: .horizontal,
        alignment: .center,
        distribution: .fillProportionally,
        spacing: C.UI.logoImageViewSpacing
    )

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let detailsStackFrame = convert(detailsStack.frame, from: detailsStack.superview)
        separatorInset = UIEdgeInsets(
            top: 0,
            left: detailsStackFrame.minX,
            bottom: 0,
            right: bounds.width - detailsStackFrame.maxX
        )

        for subview in subviews where (subview.bounds.height <= 1) && (subview != contentView) {
            // hide separators with full width of the cell (section separators)
            subview.isHidden = (subview.bounds.width == bounds.width)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
    }

    func configure(with cellModel: PortfolioItemCellModel) {
        tickerLabel.text = cellModel.ticker
        nameLabel.text = cellModel.name
        priceChangeLabel.text = cellModel.priceChange
        valueLabel.text = cellModel.value
        quantityLabel.text = cellModel.quantity
        gainLabel.attributedText = cellModel.gain

        logoImageView.layer.borderWidth = 1
        logoImageView.image = generatePlaceholderLogo(
            letter: cellModel.name.first ?? "?",
            backgroundColor: UIColor(hex: cellModel.backgroundColor),
            textColor: UIColor(hex: cellModel.textColor)
        )
    }

    func setLogo(image: UIImage) {
        logoImageView.layer.borderWidth = 0
        logoImageView.image = image
    }

    private func setupViews() {
        backgroundColor = .systemBackground
        selectedBackgroundView = UIView {
            $0.backgroundColor = .systemGray.withAlphaComponent(0.2)
        }
        contentView.addSubview(mainStack)
    }

    private func setupConstraints() {
        mainStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(C.UI.logoImageViewSpacing)
            make.top.bottom.trailing.equalToSuperview().inset(C.UI.doubleSpacing)
        }

        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(C.UI.logoSize)
        }

        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        gainLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        quantityLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        tickerLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        priceChangeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func generatePlaceholderLogo(
        letter: Character,
        backgroundColor: UIColor?,
        textColor: UIColor?
    ) -> UIImage? {
        let size = C.UI.placeholderImageSize
        let backgroundColor = backgroundColor ?? .systemGray
        let textColor = textColor ?? .white
        let fontSize: CGFloat = size * 0.5

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let letterAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle,
        ]
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        backgroundColor.setFill()
        UIRectFill(rect)

        var textRect = rect
        textRect.origin.y = size / 2 - fontSize * 0.6
        String(letter).draw(in: textRect, withAttributes: letterAttributes)

        let logo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return logo
    }
}

// MARK: - Constants

private extension C.UI {
    static let verticalSpacing: CGFloat = spacing / 4
    static let logoImageViewSpacing: CGFloat = spacing * 1.5
    static let logoSize: CGFloat = 54
    static let placeholderImageSize: CGFloat = 128
    static let logoCornerRadiusRatio: CGFloat = 0.5
}
