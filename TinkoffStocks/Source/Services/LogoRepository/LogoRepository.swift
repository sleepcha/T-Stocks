//
//  LogoRepository.swift
//  TinkoffStocks
//
//  Created by sleepcha on 6/3/24.
//

import UIKit

// MARK: - LogoRepository

protocol LogoRepository {
    typealias LogoResult = Result<UIImage, LogoRepositoryError>
    func getLogo(_ fileName: String, completion: @escaping Handler<UIImage?>)
}

// MARK: - LogoRepositoryImpl

final class LogoRepositoryImpl: LogoRepository {
    enum LogoSize: String {
        case x160, x320, x640
    }

    private let client: HTTPClient
    private let cache = Cache<UIImage>(countLimit: C.memoryCacheItemCountLimit)
    private let logoSize: LogoSize

    init(client: HTTPClient = LogoClient(), logoSize: LogoSize) {
        self.client = client
        self.logoSize = logoSize
    }

    func getLogo(_ fileName: String, completion: @escaping Handler<UIImage?>) {
        let completion = { (image: UIImage?) in
            DispatchQueue.mainSync { completion(image) }
        }

        let imageName = fileName.replacingOccurrences(
            of: ".png",
            with: "\(logoSize.rawValue).png",
            options: [.anchored, .backwards]
        )

        if let cachedImage = cache[imageName] {
            completion(cachedImage)
            return
        }

        guard let url = URL(string: imageName) else {
            completion(nil)
            return
        }

        let httpRequest = HTTPRequest(.get, path: url)
        client.fetchDataTask(httpRequest, cacheMode: .policy) { [weak self] in
            guard let data = $0.success, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            completion(image)
            self?.cache[imageName] = image
        }.resume()
    }
}

// MARK: - Constants

private extension C {
    static let memoryCacheItemCountLimit = 500
}
