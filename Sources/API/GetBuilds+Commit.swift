import Foundation
import Result
import ProcedureKit
import ProcedureKitNetwork
import Utilities
import Domain


// MARK: - Functional API

extension API.Builds {

    public static func get(for commit: LongHash, _ state: Build.State? = .passed, in pipeline: Pipeline, completion: @escaping (Result<[Build], Error>) -> Void) {

        let api = Environment.Read(.apiKey)
        let get = GetCommit(pipeline: pipeline, commit: commit, state: state)

        get.addDidFinishBlockObserver { (get, error) in
            guard let builds = get.output.success else {
                completion(.failure(error.map { .underlying($0) } ?? .unknown))
                return
            }
            completion(.success(builds))
        }

        API.queue.addOperations(api, get)
    }

    public static func passed(commit: LongHash, in pipeline: Pipeline, completion: @escaping (Result<Bool, Error>) -> Void) {
        get(for: commit, .passed, in: pipeline) { result in
            completion(result.map { builds in
                guard let build = builds.first, case .passed = build.state else {
                    return false
                }
                return true
            })
        }
    }
}



// MARK: Procedure

extension API.Builds {

    public final class GetCommit: GroupProcedure, InputProcedure, OutputProcedure {

        public var input: Pending<API.Key> = .pending
        public var output: Pending<ProcedureResult<[Build]>> = .pending

        public init(session: NetworkSession = URLSession.shared, pipeline: Pipeline, commit: LongHash, state: Build.State? = .passed) {

            var filters: [Filter] = [.commit(commit)]
            if let state = state {
                filters.append(.state(state))
            }

            let get = Get(session: session, pipeline: pipeline, filters: filters)

            super.init(operations: [get])

            bind(to: get)
            bind(from: get)
        }
    }
}

