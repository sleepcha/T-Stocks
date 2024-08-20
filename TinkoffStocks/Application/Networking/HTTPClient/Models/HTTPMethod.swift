enum HTTPMethod {
    case get, post, put, patch, delete
    case custom(String)

    var rawValue: String {
        switch self {
        case .get: "GET"
        case .post: "POST"
        case .put: "PUT"
        case .patch: "PATCH"
        case .delete: "DELETE"
        case .custom(let method): method.uppercased()
        }
    }
}
