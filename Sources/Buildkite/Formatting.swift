import Foundation


class Formatters {

    static let shared = Formatters()

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        return dateFormatter
    }()

    private init() { }
}

public extension DateFormatter {

    static var buildkiteDateFormatter = Formatters.shared.dateFormatter
}
