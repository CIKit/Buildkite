import Foundation

public enum BuildkiteError: Swift.Error {
    case missingEnvironmentKey(Environment.Key)
    case underlying(Swift.Error)
    case unknown
}
