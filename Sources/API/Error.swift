import Foundation

public enum Error: Swift.Error {
    case underlying(Swift.Error)
    case unknown
}
