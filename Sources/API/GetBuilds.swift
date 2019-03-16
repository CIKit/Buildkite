import Foundation
import Result
import ProcedureKit
import ProcedureKitNetwork
import Utilities
import Domain


// MARK: - Functional API

extension API.Builds {


    /// Gets Buildkite builds
    ///
    /// - Parameters:
    ///   - pipeline: a `Pipeline` value.
    ///   - filters: and array of query filters
    ///   - completion: block which receives an array of `Build` values as a successful Result.
    public static func get(in pipeline: Pipeline, filters: [Filter] = [], completion: @escaping (Result<[Build], Error>) -> Void) {

        let api = Environment.Read(.apiKey)
        let get = Get(pipeline: pipeline, filters: filters).injectResult(from: api)

        get.addDidFinishBlockObserver { (get, error) in
            guard let builds = get.output.success else {
                completion(.failure(error.map { .underlying($0) } ?? .unknown))
                return
            }
            completion(.success(builds))
        }

        API.queue.addOperations(api, get)
    }
}




// MARK: Procedure

extension API.Builds {

    public final class Get: GroupProcedure, InputProcedure, OutputProcedure {

        public var input: Pending<API.Key> = .pending
        public var output: Pending<ProcedureResult<[Build]>> = .pending

        public init(session: NetworkSession = URLSession.shared, pipeline: Pipeline, filters: [Filter] = []) {

            guard let url = URL(string: "builds", relativeTo: pipeline.url(relativeTo: API.server)) else {
                fatalError("Unable to create URL for Buildkite builds")
            }

            let makeURLRequest = MakeURLRequest(url: url.appendingQueryParameters(filters.URLQueryParameters))

            let get = NetworkProcedure { NetworkDataProcedure(session: session) }
                .injectResult(from: makeURLRequest)

            let decode = DecodeJSONProcedure<[Build]>(dateDecodingStrategy: .formatted(.buildkiteDateFormatter))
                .injectPayload(fromNetwork: get)

            super.init(operations: [makeURLRequest, get, decode])

            bind(to: makeURLRequest)
            bind(from: decode)

            #if DEBUG
            makeURLRequest.addDidFinishBlockObserver { (makeRequest, error) in
                if let request = makeRequest.output.success {
                    makeRequest.log.debug.message("Network Request: \(request)")
                }
            }

            decode.addDidFinishBlockObserver { (decode, error) in
                if let _ = error {
                    if let data = decode.input.value, let json = String(data: data, encoding: .utf8) {
                        decode.log.debug.message("Failed to decode: \(json)")
                    }
                }
            }
            #endif
        }
    }
}


// MARK: - Helpers

fileprivate extension Array where Element == API.Builds.Filter {

    var URLQueryParameters: [String: String] {
        return makeURLQueryParameters()
    }

    private func makeURLQueryParameters() -> [String: String] {
        var params: [String: String] = [:]

        for item in self {
            switch item {
            case let .state(state):
                params["state"] = state.rawValue
            case let .commit(longHash):
                params["commit"] = longHash
            }
        }

        return params
    }
}

