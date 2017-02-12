import HTTP
import JSON

class TodoURLMiddleware: Middleware {
    func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        let response = try chain.respond(to: request)
        guard let node = response.json?.node else { return response }
        let modified = node.appendedUrl(for: request)
        response.json = JSON(modified)
        return response
    }
}

extension Node {
    fileprivate func appendedUrl(for request: Request) -> Node {
        if let array = nodeArray {
            let mapped = array.map { $0.appendedUrl(for: request) }
            return Node(mapped)
        }

        guard
            let id = self["id"]?.string,
            let baseUrl = request.baseUrl
            else { return self }

        var node = self
        let url = baseUrl + "todos/\(id)"
        node["url"] = .string(url)
        return node
    }
}

extension Request {
    var baseUrl: String? {
        guard let host = headers["Host"]?.finished(with: "/") else { return nil }
        return "\(uri.scheme)://\(host)"
    }
}
