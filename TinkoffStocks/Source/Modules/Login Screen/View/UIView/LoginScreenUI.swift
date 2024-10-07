//
//  LoginScreenUI.swift
//  TinkoffStocks
//
//  Created by sleepcha on 8/14/24.
//

import UIKit

// MARK: - LoginScreenUI

final class LoginScreenUI: UIView {
    lazy var tokenField = PaddedTextField {
        $0.placeholder = C.tokenFieldPlaceholder
        $0.tintColor = .brandAccent
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
        $0.onTintColor = .brandAccent
    }

    let rememberMeSwitch = UISwitch {
        $0.isOn = true
        $0.onTintColor = .brandAccent
    }

    let loginButton = LoadingButton {
        $0.setTitle(C.loginButtonTitle, for: .normal)
        $0.tintColor = .brandAccent
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black.withAlphaComponent(0.5), for: .highlighted)
    }

    let scrollView = VerticalScrollView()

    private lazy var mainStack = {
        let sandboxStack = UIStackView(
            views: [
                UILabel {
                    $0.text = C.sandboxLabelText
                    $0.font = .preferredFont(forTextStyle: .body)
                    $0.textColor = .brandLabel
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                },
                sandboxSwitch,
            ],
            alignment: .center,
            spacing: 8
        )

        let rememberMeStack = UIStackView(
            views: [
                UILabel {
                    $0.text = C.rememberMeLabelText
                    $0.font = .preferredFont(forTextStyle: .body)
                    $0.textColor = .brandLabel
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                },
                rememberMeSwitch,
            ],
            alignment: .center,
            spacing: 8
        )

        let titleStack = UIStackView(
            views: [
                UILabel {
                    $0.text = C.title
                    $0.font = .preferredFont(forTextStyle: .largeTitle).withTraits(.traitBold)
                    $0.textColor = .brandLabel
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                },
                UILabel {
                    $0.text = C.subtitle
                    $0.font = .preferredFont(forTextStyle: .subheadline)
                    $0.textColor = .secondaryLabel
                    $0.adjustsFontForContentSizeCategory = true
                    $0.numberOfLines = 0
                },
            ],
            axis: .vertical,
            spacing: C.UI.doubleSpacing
        )

        let tokenStack = UIStackView(
            views: [
                tokenField,
                sandboxStack,
                rememberMeStack,
            ],
            axis: .vertical,
            spacing: C.UI.doubleSpacing * 2
        )

        return UIStackView(
            views: [
                titleStack,
                tokenStack,
                loginButton,
            ],
            axis: .vertical,
            spacing: C.UI.doubleSpacing * 3
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
        tokenField.snp.makeConstraints { make in
            make.height.equalTo(C.textFieldHeight)
        }

        loginButton.snp.makeConstraints { make in
            make.height.equalTo(C.buttonHeight)
        }

        mainStack.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview().inset(C.UI.doubleSpacing * 3)
        }

        scrollView.snp.makeConstraints { make in
            make.directionalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
}

// MARK: - Constants

private extension C {
    static let tokenFieldPlaceholder = String(localized: "LoginScreen.tokenField.placeholder", defaultValue: "Ваш токен Invest API")
    static let loginButtonTitle = String(localized: "LoginScreen.loginButton.title", defaultValue: "Войти")
    static let sandboxLabelText = String(localized: "LoginScreen.sandboxLabel.text", defaultValue: "Режим песочницы")
    static let rememberMeLabelText = String(localized: "LoginScreen.rememberMeLabel.text", defaultValue: "Запомнить меня")
    static let title = String(localized: "LoginScreen.title", defaultValue: "Введите токен")
    static let subtitle = String(localized: "LoginScreen.subtitle", defaultValue: "Для входа в Т-Инвестиции")

    static let textFieldHeight: CGFloat = 48
    static let buttonHeight: CGFloat = 60
}
