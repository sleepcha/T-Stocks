//
//  LogoRepository.swift
//  TinkoffStocks
//
//  Created by sleepcha on 6/3/24.
//

import UIKit

// MARK: - LogoRepository

protocol LogoRepository {
    func getLogo(_ fileName: String, completion: @escaping Handler<Result<UIImage, LogoRepositoryError>>)
}

// MARK: - LogoRepositoryImpl

final class LogoRepositoryImpl: LogoRepository {
    enum LogoSize: String {
        case x160, x320, x640
    }

    private let client: HTTPClient
    private let logoSize: LogoSize
    private let cache: Cache<UIImage>

    init(client: HTTPClient = LogoClient(), logoSize: LogoSize, dateProvider: @escaping DateProvider = Date.init) {
        self.client = client
        self.logoSize = logoSize
        self.cache = Cache(dateProvider: dateProvider, countLimit: C.memoryCacheItemCountLimit)
    }

    func getLogo(_ fileName: String, completion: @escaping Handler<Result<UIImage, LogoRepositoryError>>) {
        let completion = { (result: Result<UIImage, LogoRepositoryError>) in
            DispatchQueue.mainSync { completion(result) }
        }

        let imageName = fileName.replacingOccurrences(
            of: ".png",
            with: "\(logoSize.rawValue).png",
            options: [.anchored, .backwards]
        )

        if let cachedImage = cache.get(key: imageName) {
            completion(.success(cachedImage))
            return
        }

        guard let url = URL(string: imageName) else {
            completion(.failure(.invalidURL))
            return
        }

        let httpRequest = HTTPRequest(.get, path: url)
        client.fetchDataTask(httpRequest, cacheMode: .policy) { [weak cache] result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                cache?.store(key: imageName, value: image)
                completion(image.map(Result.success) ?? .failure(.invalidImage))
            case .failure(let error):
                completion(.failure(LogoRepositoryError(httpClientError: error)))
                return
            }
        }.resume()
    }
}

// MARK: - Constants

private extension C {
    static let memoryCacheItemCountLimit = 500
}
