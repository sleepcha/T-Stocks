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
    func getPlaceholder(letter: Character) -> UIImage
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

    func getPlaceholder(letter: Character) -> UIImage {
        let size: CGFloat = switch logoSize {
        case .x160: 160
        case .x320: 320
        case .x640: 640
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let fontSize: CGFloat = size * 0.5
        let letterAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle,
        ]
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        UIColor.systemGray.setFill()
        UIRectFill(rect)

        var textRect = rect
        textRect.origin.y = size / 2 - fontSize * 0.6
        String(letter).draw(in: textRect, withAttributes: letterAttributes)

        let logo = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return logo!
    }

    func getLogo(_ fileName: String, completion: @escaping (LogoResult) -> Void) -> AsyncTask {
        AsyncTask { [self] task in
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

            let dataTask = client.fetchDataTask(GET(url), cacheMode: .policy) { result in
                let result = result
                    .mapError(LogoRepositoryError.init)
                    .flatMap { UIImage(data: $0).map(Result.success) ?? .failure(.invalidImage) }
                completion(result)
            }
            task.addCancellationHandler(dataTask.cancel)
            dataTask.resume()
        }
    }
}
