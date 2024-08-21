//
//  LoginScreen.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/14/24.
//

import SnapKit
import UIKit

// MARK: - Constants

private enum Constants {
    static let defaultSpacing: CGFloat = 48
}

private extension String {
    static let tokenFieldPlaceholder = String(localized: "LoginScreen.tokenField.placeholder", defaultValue: "Ваш токен Invest API")
    static let loginButtonTitle = String(localized: "LoginScreen.loginButton.title", defaultValue: "Войти")
    static let sandboxLabelText = String(localized: "LoginScreen.sandboxLabel.text", defaultValue: "Режим песочницы")
    static let rememberMeLabelText = String(localized: "LoginScreen.rememberMeLabel.text", defaultValue: "Запомнить меня")
    static let title = String(localized: "LoginScreen.title", defaultValue: "Введите токен")
    static let subtitle = String(localized: "LoginScreen.subtitle", defaultValue: "Для входа в Т-Инвестиции")
}

// MARK: - LoginScreen

final class LoginScreen: UIView {
    lazy var tokenField = PaddedTextField {
        $0.placeholder = .tokenFieldPlaceholder
        $0.tintColor = .brand
        $0.backgroundColor = .secondarySystemBackground
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        $0.layer.cornerRadius = 8
        $0.returnKeyType = .done
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.rightView = helpButton
        $0.rightViewMode = .unlessEditing
        $0.clearButtonMode = .whileEditing
    }

    let helpButton = UIButton {
        let imageConfig = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body))
        let helpIcon = UIImage(systemName: "questionmark.circle", withConfiguration: imageConfig)
        $0.setImage(helpIcon, for: .normal)
        $0.tintColor = .secondaryLabel
        $0.contentMode = .scaleAspectFit
        $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }

    let sandboxSwitch = UISwitch {
        $0.isOn = false
        $0.onTintColor = .brand
    }

    let rememberMeSwitch = UISwitch {
        $0.isOn = true
        $0.onTintColor = .brand
    }

    let loginButton = LoadingButton {
        $0.setTitle(.loginButtonTitle, for: .normal)
        $0.tintColor = .brand
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black.withAlphaComponent(0.5), for: .highlighted)
    }

    let scrollView = VerticalScrollView()

    private lazy var mainStack = {
        let sandboxStack = UIStackView(
            views: [
                UILabel(.sandboxLabelText, style: .body),
                sandboxSwitch,
            ],
            alignment: .center,
            spacing: 8
        )

        let rememberMeStack = UIStackView(
            views: [
                UILabel(.rememberMeLabelText, style: .body),
                rememberMeSwitch,
            ],
            alignment: .center,
            spacing: 8
        )

        let titleStack = UIStackView(
            views: [
                UILabel(.title, style: .title),
                UILabel(.subtitle, style: .subtitle),
            ],
            axis: .vertical,
            spacing: 16
        )

        let tokenStack = UIStackView(
            views: [
                tokenField,
                sandboxStack,
                rememberMeStack,
            ],
            axis: .vertical,
            spacing: 24
        )

        return UIStackView(
            views: [
                titleStack,
                tokenStack,
                loginButton,
            ],
            axis: .vertical,
            spacing: Constants.defaultSpacing
        )
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .systemBackground
        scrollView.contentView.addSubview(mainStack)
        addSubview(scrollView)
    }

    private func setupConstraints() {
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        tokenField.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        loginButton.snp.makeConstraints { make in
            make.height.equalTo(60)
        }

        mainStack.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview().inset(Constants.defaultSpacing)
        }

        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(keyboardLayoutGuide.snp.top)
        }
    }
}
