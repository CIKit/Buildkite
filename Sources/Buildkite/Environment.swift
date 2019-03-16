import Foundation

public enum Environment { /* Namespace */

    public enum Key: String {

        /// As defined by Buildkite
        case ci = "CI"
        case buildkite = "BUILDKITE"
        case agentId = "BUILDKITE_AGENT_ID"
        case agentName = "BUILDKITE_AGENT_NAME"
        case branch = "BUILDKITE_BRANCH"
        case buildCreator = "BUILDKITE_BUILD_CREATOR"
        case buildCreatorEmail = "BUILDKITE_BUILD_EMAIL"
        case buildId = "BUILDKITE_BUILD_ID"
        case buildNumber = "BUILDKITE_BUILD_NUMBER"
        case buildURL = "BUILDKITE_BUILD_URL"
        case command = "BUILDKITE_COMMAND"
        case commit = "BUILDKITE_COMMIT"
        case jobId = "BUILDKITE_JOB_ID"
        case label = "BUILDKITE_LABEL"
        case message = "BUILDKITE_MESSAGE"
        case organization = "BUILDKITE_ORGANIZATION_SLUG"
        case pipelineDefaultBranch = "BUILDKITE_PIPELINE_DEFAULT_BRANCH"
        case pipelineProvider = "BUILDKITE_PIPELINE_PROVIDER"
        case pipeline = "BUILDKITE_PIPELINE_SLUG"
        case pullRequest = "BUILDKITE_PULL_REQUEST"
        case pullRequestBaseBranch = "BUILDKITE_PULL_REQUEST_BASE_BRANCH"
        case pullRequestRepo = "BUILDKITE_PULL_REQUEST_REPO"
        case rebuiltFromBuildId = "BUILDKITE_REBUILT_FROM_BUILD_ID"
        case rebuildFromBuildNumber = "BUILDKITE_REBUILT_FROM_BUILD_NUMBER"
        case repo = "BUILDKITE_REPO"
        case repoSSHHost = "BUILDKITE_REPO_SSH_HOST"
        case retryCount = "BUILDKITE_RETRY_COUNT"
        case scriptPath = "BUILDKITE_SCRIPT_PATH"
        case source = "BUILDKITE_SOURCE"
        case tag = "BUILDKITE_TAG"
        case timeout = "BUILDKITE_TIMEOUT"
        case triggeredFromBuildId = "BUILDKITE_TRIGGERED_FROM_BUILD_ID"
        case triggeredFromBuildNumber = "BUILDKITE_TRIGGERED_FROM_BUILD_NUMBER"
        case triggeredFromBuildPipelineSlug = "BUILDKITE_TRIGGERED_FROM_BUILD_PIPELINE_SLUG"

        /// Additional Agent environment variables
        case apiKey = "BUILDKITE_API_KEY"
    }

    static func read(_ key: Key) -> String? {
        return ProcessInfo.processInfo.environment[key.rawValue]
    }
}

public extension String {

    static func buildkite(_ key: Environment.Key) -> String? {
        return Environment.read(key)
    }
}



// MARK: - Read Environment Keys

import ProcedureKit

extension Environment {

    public final class Read: ResultProcedure<String> {
        public init(_ key: Environment.Key) {
            super.init {
                guard let result = Environment.read(key) else {
                    throw BuildkiteError.missingEnvironmentKey(key)
                }
                return result
            }
        }
    }
}
