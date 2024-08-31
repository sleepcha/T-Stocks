import Foundation

struct HTTPResponse: CustomStringConvertible {
    let url: URL?
    let statusCode: Int
    let headers: [String: String]
    let data: Data?

    var description: String {
        let urlString = url?.absoluteString ?? "[No URL]"
        let headers = headers
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")

        return "HTTP \(statusCode): \(urlString)\n\(headers)"
    }
}
