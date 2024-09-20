//
//  LogoRepository.swift
//  TinkoffStocks
//
//  Created by sleepcha on 6/3/24.
//

import Foundation

// MARK: - LogoRepository

protocol LogoRepository {
    typealias LogoResult = Result<Data, LogoRepositoryError>
    func getLogo(_ fileName: String, completion: @escaping (LogoResult) -> Void) -> AsyncTask
}

// MARK: - LogoRepositoryImpl

final class LogoRepositoryImpl: LogoRepository {
    enum LogoSize: String {
        case x160, x320, x640
    }

    private let client: HTTPClient
    private let logoSize: LogoSize

    init(client: HTTPClient, logoSize: LogoSize) {
        self.client = client
        self.logoSize = logoSize
    }

    func getLogo(_ fileName: String, completion: @escaping (LogoResult) -> Void) -> AsyncTask {
        AsyncTask(id: "getLogo:\(fileName)") { [self] task in
            let completion = { (result: LogoResult) in
                completion(result)
                task.done(error: result.failure)
            }

            let imageName = fileName.replacingOccurrences(
                of: ".png",
                with: "\(logoSize.rawValue).png",
                options: [.anchored, .backwards]
            )

            guard let url = URL(string: imageName) else {
                completion(.failure(.invalidURL))
                return
            }

            let httpRequest = HTTPRequest(.get, path: url)
            let dataTask = client.fetchDataTask(httpRequest, cacheMode: .policy) { result in
                let result = result.mapError(LogoRepositoryError.init)
                completion(result)
            }
            task.addCancellationHandler(dataTask.cancel)
            dataTask.resume()
        }
    }
}
