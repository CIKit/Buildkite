import XCTest
@testable import Buildkite

final class FormatterTests: XCTestCase {

    func test__buildkite_date_formatter() {
        let formatter: DateFormatter = .buildkiteDateFormatter
        let date = formatter.date(from: "2019-03-14T13:01:02.253Z")
        XCTAssertNotNil(date)
    }
}
