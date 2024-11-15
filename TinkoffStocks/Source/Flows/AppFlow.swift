//
//  AppFlow.swift
//  T-Stocks
//
//  Created by sleepcha on 8/31/24.
//

import UIKit

final class AppFlow: AppCoordinator {
    private let authService: AuthService
    private var launchWindow: UIWindow?

    init(windowScene: UIWindowScene) {
        self.authService = AuthServiceImpl(
            keychainService: KeychainServiceImpl(service: C.ID.keychainService),
            networkManagerFactory: NetworkManagerFactoryImpl(),
            sandboxServiceFactory: SandboxServiceFactoryImpl()
        )
        self.launchWindow = UIWindow(windowScene: windowScene)
        super.init(window: UIWindow(windowScene: windowScene))
    }

    override func start() {
        presentLaunchWindow()

        authService.getStoredAuthData { [weak self] authData in
            guard let self else { return }

            startLaunchScreenLoader()

            guard let authData else {
                startLoginFlow()
                dismissLaunchWindow()
                return
            }

            authService.login(auth: authData, shouldSave: false) { result in
                switch result {
                case .failure(let error):
                    if case .unauthorized = error { self.authService.logout() }
                    self.startLoginFlow(showing: error)
                case .success:
                    self.startMainFlow()
                }
                self.dismissLaunchWindow()
            }
        }
    }

    private func presentLaunchWindow() {
        launchWindow?.windowLevel = .normal + 1
        launchWindow?.rootViewController = LaunchScreenVC()
        launchWindow?.makeKeyAndVisible()
    }

    private func startLaunchScreenLoader() {
        DispatchQueue.mainSync {
            (launchWindow?.rootViewController as? LaunchScreenVC)?.startLoader()
        }
    }

    private func startLoginFlow(showing error: Error? = nil) {
        DispatchQueue.mainSync {
            let loginFlow = LoginFlow(authService: authService, showing: error)
            loginFlow.onStopFlow { [weak self] in
                self?.startMainFlow()
            }

            present(loginFlow)
        }
    }

    private func startMainFlow() {
        DispatchQueue.mainSync {
            let mainFlow = MainFlow(authService: authService)
            mainFlow.onStopFlow { [weak self] in
                self?.authService.logout()
                self?.startLoginFlow()
            }

            present(mainFlow)
        }
    }

    private func dismissLaunchWindow() {
        DispatchQueue.mainSync {
            launchWindow?.isHidden = true
            launchWindow = nil
        }
    }
}
