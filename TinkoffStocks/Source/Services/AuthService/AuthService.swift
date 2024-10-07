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
    func getStoredAuthData(completion: @escaping (AuthData?) -> Void)
    func login(auth: AuthData, shouldSave: Bool, completion: @escaping (RepositoryResult<[AccountData]>) -> Void)
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
    private let getAccounts = API.getAccounts(GetAccountsRequest(status: .open))

    init(keychainService: KeychainService, networkManagerFactory: NetworkManagerFactory, sandboxServiceFactory: SandboxServiceFactory) {
        self.keychainService = keychainService
        self.networkManagerFactory = networkManagerFactory
        self.sandboxServiceFactory = sandboxServiceFactory
    }

    func isValidToken(text: String) -> Bool {
        text.count == C.tokenLength && text.hasPrefix(C.tokenPrefix)
    }

    func getStoredAuthData(completion: @escaping (AuthData?) -> Void) {
        keychainService.read(C.Keys.authTokenKeychain, type: AuthData.self) {
            completion($0.success)
        }
    }

    func login(auth: AuthData, shouldSave: Bool, completion: @escaping (RepositoryResult<[AccountData]>) -> Void) {
        let networkManager = networkManagerFactory.build(token: auth.token, isSandbox: auth.isSandbox)

        networkManager.fetch(getAccounts) { [weak self] result in
            guard let self else { return }
            let completion: (RepositoryResult<[AccountData]>) -> Void = {
                guard let accounts = $0.success else {
                    self.logout()
                    return
                }
                self.accounts = accounts
                completion($0)
            }

            switch result {
            case .success(let response):
                if shouldSave { saveAuthData(auth) }
                self.networkManager = networkManager
                isSandbox = auth.isSandbox

                if isSandbox, response.accounts.isEmpty {
                    createStubAccount(networkManager: networkManager, completion: completion)
                } else {
                    let accountsData = response.accounts.compactMap(AccountData.init)
                    completion(.success(accountsData))
                }
            case .failure(let networkManagerError):
                if case .unauthorized = networkManagerError { removeAuthData() }
                completion(.failure(RepositoryError(networkManagerError)))
            }
        }.perform()
    }

    func logout() {
        sandboxServiceFactory.build(networkManager: networkManager!).closeAccount(self.accounts.first!.id) { _ in }.perform()
        networkManager?.clearCache()
        networkManager = nil
        accounts = []
        removeAuthData()
    }

    private func saveAuthData(_ auth: AuthData) {
        keychainService.save(C.Keys.authTokenKeychain, data: auth) { error in
            if let error { print(error.localizedDescription) }
        }
    }

    private func removeAuthData() {
        keychainService.delete(C.Keys.authTokenKeychain) { _ in }
    }

    private func createStubAccount(networkManager: NetworkManager, completion: @escaping (RepositoryResult<[AccountData]>) -> Void) {
        var accountsData = [AccountData]()

        AsyncChain {
            self.sandboxServiceFactory
                .build(networkManager: networkManager)
                .createAccount { _ in }
        }.then {
            networkManager.fetch(self.getAccounts) { result in
                accountsData = result.success?.accounts.compactMap(AccountData.init) ?? []
            }
        }.handle { state in
            switch state {
            case .completed:
                completion(.success(accountsData))
            case .failed(let error as RepositoryError):
                completion(.failure(error))
            case .cancelled:
                completion(.failure(.taskCancelled))
            default:
                // degenerate cases, do not happen if all tasks in the chain complete with RepositoryError
                completion(.failure(.taskCancelled))
            }
        }.perform()
    }
}

// MARK: - Model mapping

private extension AccountData {
    init?(_ account: Account) {
        guard [.fullAccess, .readOnly].contains(account.accessLevel) else { return nil }

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

// MARK: - Constants

private extension C {
    static let tokenLength = 88
    static let tokenPrefix = "t."
}
