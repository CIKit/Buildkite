import Foundation

public struct Pipeline {
    public let organization: Organization
    public let slug: String

    public init(organization: Organization, slug: String) {
        self.organization = organization
        self.slug = slug
    }
}


extension Pipeline {

    public func url(relativeTo baseURL: URL?) -> URL? {
        return URL(string: "organizations/\(organization.slug)/pipelines/\(slug)", relativeTo: baseURL)
    }
}
