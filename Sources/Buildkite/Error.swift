import Foundation

public enum Error: Swift.Error {
    case missingEnvironmentKey(Environment.Key)
    case underlying(Swift.Error)
    case unknown
}
