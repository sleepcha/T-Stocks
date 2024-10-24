//
//  LaunchScreenVC.swift
//  T-Stocks
//
//  Created by sleepcha on 8/13/24.
//

import UIKit

// MARK: - LaunchScreenVC

final class LaunchScreenVC: UIViewController {
    private let loader = UIActivityIndicatorView {
        $0.color = .white
        $0.style = .large
    }

    private let imageView = UIImageView(image: .launchScreenLogo)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    func startLoader() {
        loader.startAnimating()
    }

    private func setupViews() {
        view.backgroundColor = .launchScreenBackground
        view.addSubview(imageView)
        view.addSubview(loader)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(C.logoImageSize)
        }

        loader.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().multipliedBy(0.9)
        }
    }
}

// MARK: - Constants

private extension C {
    static let logoImageSize = 128
}
