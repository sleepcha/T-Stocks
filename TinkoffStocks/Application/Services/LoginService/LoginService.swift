//
//  LoginService.swift
//  T-Stocks
//
//  Created by sleepcha on 8/6/24.
//

import Foundation

// MARK: - Constants

private extension C {
    static let tokenLength = 88
    static let tokenPrefix = "t."
}

// MARK: - LoginService

protocol LoginService {
    /// Non-nil value of `networkManager` indicates that the user is logged in.
    var networkManager: NetworkManager? { get }
    var isSandbox: Bool { get }

    func isValidToken(text: String) -> Bool
    func getStoredAuthData(completion: @escaping (AuthData?) -> Void)
    func login(auth: AuthData, shouldSave: Bool, completion: @escaping (RepositoryResult<[AccountData]>) -> Void)
    func logout()
}

// MARK: - LoginServiceImpl

final class LoginServiceImpl: LoginService {
    private(set) var networkManager: NetworkManager?
    private(set) var isSandbox: Bool = false

    private let keychainService: KeychainService
    private let networkManagerAssembly: NetworkManagerAssembly
    private let sandboxServiceAssembly: SandboxServiceAssembly

    init(keychainService: KeychainService, networkManagerAssembly: NetworkManagerAssembly, sandboxServiceAssembly: SandboxServiceAssembly) {
        self.keychainService = keychainService
        self.networkManagerAssembly = networkManagerAssembly
        self.sandboxServiceAssembly = sandboxServiceAssembly
    }

    func isValidToken(text: String) -> Bool {
        text.count == C.tokenLength && text.hasPrefix(C.tokenPrefix)
    }

    func getStoredAuthData(completion: @escaping (AuthData?) -> Void) {
        keychainService.read(.authToken, type: AuthData.self) {
            completion($0.success)
        }
    }

    func login(auth: AuthData, shouldSave: Bool, completion: @escaping (RepositoryResult<[AccountData]>) -> Void) {
        let networkManager = networkManagerAssembly.build(token: auth.token, isSandbox: auth.isSandbox)

        networkManager.fetch(API.getAccounts) { result in
            switch result {
            case .success(let response):
                if shouldSave { self.saveAuthData(auth) }
                self.networkManager = networkManager
                self.isSandbox = auth.isSandbox

                let accounts = response.accounts
                if self.isSandbox, accounts.isEmpty {
                    self.createStubAccount(networkManager: networkManager, completion: completion)
                } else {
                    completion(.success(accounts.compactMap(AccountData.init)))
                }
            case .failure(let networkManagerError):
                completion(.failure(RepositoryError(networkManagerError)))
            }
        }.perform()
    }

    func logout() {
        guard networkManager != nil else { return }
        networkManager?.clearCache()
        networkManager = nil
        keychainService.delete(.authToken) { _ in }
    }

    // MARK: Private

    private func saveAuthData(_ auth: AuthData) {
        keychainService.save(.authToken, data: auth) { error in
            if let error { print(error.localizedDescription) }
        }
    }

    private func createStubAccount(networkManager: NetworkManager, completion: @escaping (RepositoryResult<[AccountData]>) -> Void) {
        AsyncChain {
            self.sandboxServiceAssembly
                .build(networkManager: networkManager)
                .createAccount { _ in }
        }.then {
            networkManager.fetch(API.getAccounts) { result in
                completion(result
                    .map { $0.accounts.compactMap(AccountData.init) }
                    .mapError { _ in RepositoryError.networkError }
                )
            }
        }.perform()
    }
}

// MARK: - Model mapping

private extension AccountData {
    init?(_ account: Account) {
        guard
            account.status == .open,
            account.accessLevel == .fullAccess || account.accessLevel == .readOnly
        else { return nil }

        self.init(
            id: account.id,
            name: account.name,
            openedDate: account.openedDate,
            isIIS: account.type == .tinkoffIis,
            isReadOnly: account.accessLevel == .readOnly
        )
    }
}

// MARK: - Helpers

private extension AuthData {
    var isSandbox: Bool { server == .sandbox }
}
