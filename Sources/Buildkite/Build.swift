import Foundation

public typealias LongHash = String

public struct Build {

    public enum State: String {
        case running, scheduled, passed, failed, blocked, canceled, canceling, skipped, finished
        case notRun = "not_run"
    }

    public let id: String
    public let url: URL
    public let webURL: URL
    public let number: Int
    public let state: State
    public let blocked: Bool
    public let message: String
    public let commit: LongHash
    public let branch: String
    public let tag: String?
    public let createdAt: Date
    public let scheduledAt: Date
    public let startedAt: Date
    public let finishedAt: Date
}


// MARK: - Protocol Conformance

extension Build.State: Equatable, Codable { }

extension Build: Equatable, Codable {

    internal struct Schema: Codable {

        enum CodingKeys: String, CodingKey {
            case id, url, number, state, blocked, message, commit, branch, tag
            case webURL = "web_url"
            case createdAt = "created_at"
            case scheduledAt = "scheduled_at"
            case startedAt = "started_at"
            case finishedAt = "finished_at"
        }

        public let id: String
        public let url: String
        public let webURL: String
        public let number: Int
        public let state: State
        public let blocked: Bool
        public let message: String
        public let commit: LongHash
        public let branch: String
        public let tag: String?
        public let createdAt: Date
        public let scheduledAt: Date
        public let startedAt: Date
        public let finishedAt: Date
    }

    public init(from decoder: Decoder) throws {
        let schema = try Schema(from: decoder)
        id = schema.id
        url = try URL(schema.url)
        webURL = try URL(schema.webURL)
        number = schema.number
        state = schema.state
        blocked = schema.blocked
        message = schema.message
        commit = schema.commit
        branch = schema.branch
        tag = schema.tag
        createdAt = schema.createdAt
        scheduledAt = schema.scheduledAt
        startedAt = schema.startedAt
        finishedAt = schema.finishedAt
    }
}

