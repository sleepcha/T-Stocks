//
//  SplashScreenViewController.swift
//  T-Stocks
//
//  Created by sleepcha on 8/13/24.
//

import UIKit

// MARK: - Constants

private enum Constants {
    static let logoImageSize = 128
}

// MARK: - SplashScreenViewController

final class SplashScreenViewController: UIViewController {
    private let spinner = UIActivityIndicatorView {
        $0.color = .white
        $0.style = .large
        $0.startAnimating()
    }

    private let imageView = UIImageView(image: .launchScreenLogo)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        view.backgroundColor = .launchScreenBackground
        view.addSubview(imageView)
        view.addSubview(spinner)
    }

    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.width.height.equalTo(Constants.logoImageSize)
        }

        spinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().multipliedBy(0.9)
        }
    }

    #if DEBUG
        deinit { print("> SplashScreenViewController.deinit()") }
    #endif
}
