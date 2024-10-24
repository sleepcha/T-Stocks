//
//  AuthService.swift
//  T-Stocks
//
//  Created by sleepcha on 8/6/24.
//

import Foundation

// MARK: - AuthService

protocol AuthService {
    /// Non-nil value of `networkManager` indicates that the user is logged in.
    var networkManager: NetworkManager? { get }
    var accounts: [AccountData] { get }
    var isSandbox: Bool { get }

    func isValidToken(text: String) -> Bool
    func getStoredAuthData(completion: @escaping Handler<AuthData?>)
    func login(auth: AuthData, shouldSave: Bool, completion: @escaping Handler<Result<[AccountData], RepositoryError>>)
    func logout()
}

// MARK: - AuthServiceImpl

final class AuthServiceImpl: AuthService {
    private(set) var networkManager: NetworkManager?
    private(set) var accounts: [AccountData] = []
    private(set) var isSandbox: Bool = false

    private let keychainService: KeychainService
    private let networkManagerFactory: NetworkManagerFactory
    private let sandboxServiceFactory: SandboxServiceFactory

    init(keychainService: KeychainService, networkManagerFactory: NetworkManagerFactory, sandboxServiceFactory: SandboxServiceFactory) {
        self.keychainService = keychainService
        self.networkManagerFactory = networkManagerFactory
        self.sandboxServiceFactory = sandboxServiceFactory
    }

    func isValidToken(text: String) -> Bool {
        text.count == C.tokenLength && text.hasPrefix(C.tokenPrefix)
    }

    func getStoredAuthData(completion: @escaping Handler<AuthData?>) {
        keychainService.read(C.Keys.authTokenKeychain, type: AuthData.self) {
            completion($0.success)
        }
    }

    func login(auth: AuthData, shouldSave: Bool, completion: @escaping Handler<Result<[AccountData], RepositoryError>>) {
        let networkManager = networkManagerFactory.build(token: auth.token, isSandbox: auth.isSandbox)
        let endpoint = API.getAccounts(GetAccountsRequest(status: .open))

        networkManager.fetch(endpoint).run { [weak self] result in
            guard let self else { return }
            let completion: Handler<Result<[AccountData], RepositoryError>> = {
                self.accounts = $0.success ?? []
                completion($0)
            }

            switch result {
            case .success(let response):
                if shouldSave { saveAuthData(auth) }
                self.networkManager = networkManager
                isSandbox = auth.isSandbox

                if isSandbox, response.accounts.isEmpty {
                    sandboxServiceFactory
                        .build(networkManager: networkManager)
                        .createStubAccount(completion: completion)
                } else {
                    let accountsData = response.accounts.compactMap(AccountData.init)
                    completion(.success(accountsData))
                }
            case .failure(let error):
                completion(.failure(RepositoryError(networkManagerError: error)))
            }
        }
    }

    func logout() {
        networkManager?.clearCache()
        networkManager = nil
        accounts = []
        isSandbox = false
        removeAuthData()
    }

    private func saveAuthData(_ auth: AuthData) {
        keychainService.save(C.Keys.authTokenKeychain, data: auth) { error in
            #if DEBUG
            if let error {
                print("Unable to save auth data:", error.localizedDescription)
            }
            #endif
        }
    }

    private func removeAuthData() {
        keychainService.delete(C.Keys.authTokenKeychain) { _ in }
    }
}

// MARK: - Helpers

private extension AuthData {
    var isSandbox: Bool { server == .sandbox }
}

// MARK: - Constants

private extension C {
    static let tokenLength = 88
    static let tokenPrefix = "t."
}
