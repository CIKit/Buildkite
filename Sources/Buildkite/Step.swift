import Foundation

protocol PipelineStep {

    var label: String? { get }

}

extension Pipeline {

    public enum Step {

        public struct Concurrency: Equatable {
            public let count: Int
            public let group: String?
        }

        public enum Retry: Equatable {

            public struct Automatic: Equatable {
                public let exitStatus: String?
                public let limit: Int?
            }

            public struct Manual: Equatable {
                public let allowed: Bool?
                public let permitOnPassed: Bool?
                public let reason: String?
            }

            case automatic([Automatic]?)
            case manual(Manual?)
        }


    }

    public struct CommandStep: Equatable {

        public enum Command: Equatable {
            case command(String)
            case commands([String])
        }

        public typealias Minutes = Double

        public let command: Command
        public let label: String?
        public let identifier: String?
        public let environment: [String: String]?
        public let agents: [String: String]?
        public let artifacts: [String]?
        public let branches: String?
        public let concurrency: Step.Concurrency?


        public let parallelism: Int?
        public let retry: Step.Retry?
        public let skip: String?
        public let timeout: Minutes?
        
        public init(_ command: Command, label: String? = ":swift: :buildkite:", identifier: String? = nil, environment: [String: String]? = nil, agents: [String: String]? = nil, artifacts: [String]? = nil, branches: String? = nil, concurrency: Step.Concurrency? = nil, parallelism: Int? = nil, retry: Step.Retry? = nil, skip: String? = nil, timeout: Minutes? = nil) {
            
            self.command = command
            self.label = label
            self.identifier = identifier
            self.environment = environment
            self.agents = agents
            self.artifacts = artifacts
            self.branches = branches
            self.concurrency = concurrency
            self.parallelism = parallelism
            self.retry = retry
            self.skip = skip
            self.timeout = timeout
        }
    }
}




// MARK: - Codable

extension Pipeline.Step.Concurrency: Codable {

    enum CodingKeys: String, CodingKey {
        case count = "concurrency"
        case group = "concurrency_group"
    }
}

extension Pipeline.Step.Retry.Automatic: Codable {

    enum CodingKeys: String, CodingKey {
        case exitStatus = "exit_status"
        case limit = "limit"
    }
}

extension Pipeline.Step.Retry.Manual: Codable {

    enum CodingKeys: String, CodingKey {
        case allowed = "allowed"
        case permitOnPassed = "permit_on_passed"
        case reason = "reason"
    }
}

extension Pipeline.Step.Retry: Codable {

    private enum Discriminator: String, Codable {
        case automatic, manual
    }

    private enum CodingKeys: String, CodingKey {
        case discriminator
        case automaticOptions
        case manualOptions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(Discriminator.self, forKey: .discriminator)
        switch discriminator {
        case .automatic:
            let options = try container.decode([Automatic].self, forKey: .automaticOptions)
            self = .automatic(options)
        case .manual:
            let options = try container.decode(Manual.self, forKey: .manualOptions)
            self = .manual(options)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .automatic(options):
            try container.encodeIfPresent(options, forKey: .automaticOptions)
            try container.encode(Discriminator.automatic, forKey: .discriminator)
        case let .manual(options):
            try container.encodeIfPresent(options, forKey: .manualOptions)
            try container.encode(Discriminator.manual, forKey: .discriminator)
        }
    }
}

extension Pipeline.CommandStep: Codable {
    
    public enum DecodingError: Swift.Error {
        case missingCommand
    }
    
    private enum CodingKeys: String, CodingKey {
        case command, commands, agents, branches, concurrency, label, parallelism, plugins, retry, skip
        case commandDiscriminator
        case artifacts = "artifact_paths"
        case concurrencyGroup = "concurrency_group"
        case environment = "env"
        case identifier = "id"
        case timeout = "timeout_in_minutes"

    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let single = try container.decodeIfPresent(String.self, forKey: .command) {
            command = .command(single)
        }
        else if let multi = try container.decodeIfPresent([String].self, forKey: .commands) {
            command = .commands(multi)
        }
        else {
            throw DecodingError.missingCommand
        }
        
        agents = try container.decodeIfPresent([String: String].self, forKey: .agents)
        artifacts = try container.decodeIfPresent([String].self, forKey: .artifacts)
        branches = try container.decodeIfPresent(String.self, forKey: .branches)
        
        concurrency = try container.decodeIfPresent(Int.self, forKey: .concurrency).map {
            let group = try container.decodeIfPresent(String.self, forKey: .concurrencyGroup)
            return Pipeline.Step.Concurrency(count: $0, group: group)
        }

        environment = try container.decodeIfPresent([String: String].self, forKey: .environment)
        identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        parallelism = try container.decodeIfPresent(Int.self, forKey: .parallelism)
        retry = try container.decodeIfPresent(Pipeline.Step.Retry.self, forKey: .retry)
        skip = try container.decodeIfPresent(String.self, forKey: .skip)
        timeout = try container.decodeIfPresent(Minutes.self, forKey: .timeout)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch command {
        case let .command(command):
            try container.encode(command.quoted(), forKey: .command)
        case let .commands(commands):
            try container.encode(commands, forKey: .commands)
        }
        
        try container.encodeIfPresent(agents, forKey: .agents)
        try container.encodeIfPresent(artifacts, forKey: .artifacts)
        try container.encodeIfPresent(branches, forKey: .branches)
        try container.encodeIfPresent(concurrency?.count, forKey: .concurrency)
        try container.encodeIfPresent(concurrency?.group, forKey: .concurrencyGroup)
        try container.encodeIfPresent(environment, forKey: .environment)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encodeIfPresent(parallelism, forKey: .parallelism)
        try container.encodeIfPresent(retry, forKey: .retry)
        try container.encodeIfPresent(skip, forKey: .skip)
        try container.encodeIfPresent(timeout, forKey: .timeout)
    }
}

internal extension String {
    
    func quoted() -> String {
        return "\"\(self)\""
    }
    
    func dequoted() -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
