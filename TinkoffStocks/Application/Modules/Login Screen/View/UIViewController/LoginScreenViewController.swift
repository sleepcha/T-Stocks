//
//  LoginScreenViewController.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import UIKit

// MARK: - LoginScreenViewController

final class LoginScreenViewController: UIViewController {
    var presenter: LoginScreenPresenter!
    private let ui = LoginScreen()

    override func loadView() {
        view = ui
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewActions()
        presenter.viewReady()
    }

    private func setupViewActions() {
        ui.addGestureRecognizer(UITapGestureRecognizer(target: ui, action: #selector(UIView.endEditing)))
        ui.helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        ui.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        ui.tokenField.delegate = self
    }

    @objc private func helpButtonTapped(sender: UIButton) {
        presenter.help()
    }

    @objc private func loginButtonTapped(sender: LoadingButton) {
        let token = (ui.tokenField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        presenter.login(
            token: token,
            isSandbox: ui.sandboxSwitch.isOn,
            rememberMe: ui.rememberMeSwitch.isOn
        )
    }
}

// MARK: - LoginScreenView

extension LoginScreenViewController: LoginScreenView {
    func switchState(isLoading: Bool) {
        ui.endEditing(true)
        let controls = [ui.tokenField, ui.sandboxSwitch, ui.rememberMeSwitch, ui.sandboxSwitch]
        ui.loginButton.isLoading = isLoading
        ui.loginButton.isUserInteractionEnabled = !isLoading
        controls.forEach { $0.isEnabled = !isLoading }
    }

    func indicateInvalidToken() {
        ui.tokenField.shake()
    }

    func showErrorMessage(message: String) {
        showToast(message, kind: .error)
        dismiss(animated: false)
    }

    func showHelpDialog(_ dialog: Dialog) {
        present(dialog.make(.actionSheet), animated: true, completion: nil)
    }

    func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

// MARK: - UITextFieldDelegate

extension LoginScreenViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // self.ui.scrollView.scrollTo(textField)
            self.ui.scrollView.scrollRectToVisible(textField.frame, animated: true)
        }
    }
}
