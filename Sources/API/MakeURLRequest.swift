import Foundation
import ProcedureKit
import ProcedureKitNetwork

// MARK: - Make URL Request

final class MakeURLRequest: TransformProcedure<API.Key, URLRequest> {

    init(url: URL) {
        super.init { apiKey in
            var request = URLRequest(url: url)
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            return request
        }
    }
}
