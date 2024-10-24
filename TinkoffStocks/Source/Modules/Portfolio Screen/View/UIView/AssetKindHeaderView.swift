//
//  AssetKindHeaderView.swift
//  T-Stocks
//
//  Created by sleepcha on 10/5/24.
//

import UIKit

class AssetKindHeaderView: UITableViewHeaderFooterView {
    static let defaultHeight: CGFloat = 76

    private let titleLabel = UILabel {
        $0.font = .preferredFont(forTextStyle: .title2).withTraits(.traitBold)
        $0.textColor = .brandLabel
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(C.UI.doubleSpacing)
        }
    }

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
