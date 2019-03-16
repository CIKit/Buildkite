import Foundation

public struct Organization {
    public let slug: String

    public init(slug: String) {
        self.slug = slug
    }
}


// MARK: - Pipeline Builder

public extension Organization {

    func pipeline(_ slug: String) -> Pipeline {
        return Pipeline(organization: self, slug: slug)
    }
}



// MARK: - Protocol Conformance

extension Organization: ExpressibleByExtendedGraphemeClusterLiteral {

    public init(extendedGraphemeClusterLiteral value: String) {
        self.slug = value
    }
}

extension Organization: ExpressibleByUnicodeScalarLiteral {

    public init(unicodeScalarLiteral value: String) {
        self.slug = value
    }
}

extension Organization: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.slug = value
    }
}


// MARK: - Operator

func +(lhs: Organization, rhs: String) -> Pipeline {
    return Pipeline(organization: lhs, slug: rhs)
}
