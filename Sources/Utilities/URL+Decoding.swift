import Foundation

extension URL {

    public enum DecodingError: Error {
        case invalidURLString(String)
    }

    public init(_ string: String) throws {
        guard let url = URL(string: string) else {
            throw DecodingError.invalidURLString(string)
        }
        self = url
    }
}
