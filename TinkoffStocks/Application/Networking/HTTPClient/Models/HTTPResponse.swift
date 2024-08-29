import Foundation

struct HTTPResponse: CustomStringConvertible {
    let url: URL?
    let statusCode: Int
    let headers: [String: String]
    let data: Data?

    var description: String {
        "\(statusCode): \(url?.absoluteString ?? "[NO URL]")\n\(headers)"
    }
}
