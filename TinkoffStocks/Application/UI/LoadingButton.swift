//
//  LoadingButton.swift
//  TinkoffStocks
//
//  Created by sleepcha on 5/29/23.
//

import UIKit

class LoadingButton: FilledButton {
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                titleLabel?.isHidden = true
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
                titleLabel?.isHidden = false
            }
        }
    }

    private let spinner = UIActivityIndicatorView {
        $0.style = .medium
        $0.color = .white
        $0.hidesWhenStopped = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)

        // make spinner color match the title color
        if state == .normal { spinner.color = color }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPointMake(bounds.midX, bounds.midY)
        if spinner.center != center { spinner.center = center }
    }
}
