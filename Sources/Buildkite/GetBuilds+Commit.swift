import Foundation
import Result
import ProcedureKit
import ProcedureKitNetwork


// MARK: - Functional API

extension API.Builds {

    public static func get(for commit: LongHash, _ state: Build.State? = .passed, in pipeline: Pipeline, completion: @escaping (Result<[Build], BuildkiteError>) -> Void) {

        let get = GetCommit(for: commit, state, in: pipeline)

        get.addDidFinishBlockObserver { (get, error) in
            guard let builds = get.output.success else {
                completion(.failure(error.map { .underlying($0) } ?? .unknown))
                return
            }
            completion(.success(builds))
        }

        API.queue.addOperations(get)
    }

    public static func passed(commit: LongHash, in pipeline: Pipeline, completion: @escaping (Result<Bool, BuildkiteError>) -> Void) {

        let get = Passed(for: commit, in: pipeline)

        get.addDidFinishBlockObserver { (get, error) in
            guard let builds = get.output.success else {
                completion(.failure(error.map { .underlying($0) } ?? .unknown))
                return
            }
            completion(.success(builds))
        }

        API.queue.addOperations(get)
    }
}



// MARK: Procedure

extension API.Builds {

    public final class GetCommit: GroupProcedure, OutputProcedure {

        public var output: Pending<ProcedureResult<[Build]>> = .pending

        public init(for commit: LongHash, _ state: Build.State? = .passed, in pipeline: Pipeline, session: NetworkSession = URLSession.shared) {

            var filters: [Filter] = [.commit(commit)]
            if let state = state {
                filters.append(.state(state))
            }

            let get = Get(in: pipeline, with: filters, session: session)

            super.init(operations: [get])

            bind(from: get)
        }
    }

    public final class Passed: GroupProcedure, OutputProcedure {

        public var output: Pending<ProcedureResult<Bool>> = .pending

        public init(for commit: LongHash, in pipeline: Pipeline, session: NetworkSession = URLSession.shared) {

            let get = GetCommit(for: commit, .passed, in: pipeline, session: session)

            let parse = TransformProcedure<[Build], Bool> { builds in
                guard let build = builds.first, case .passed = build.state else {
                    return false
                }
                return true
            }.injectResult(from: get)

            super.init(operations: [get, parse])

            bind(from: parse)
        }
    }
}

