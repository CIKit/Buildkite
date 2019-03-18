import XCTest
import Yams
@testable import Buildkite

final class CommandStepTests: XCTestCase {
    
    var step: Pipeline.CommandStep!
    var encoder: YAMLEncoder!
    var decoder: YAMLDecoder!
    
    override func setUp() {
        super.setUp()
        encoder = YAMLEncoder()
        decoder = YAMLDecoder()
    }
        
    override func tearDown() {
        step = nil
        encoder = nil
        decoder = nil
        super.tearDown()
    }

    func checkCodable(for step: Pipeline.CommandStep) throws -> Pipeline.CommandStep {
        let encoded = try encoder.encode(step)
        return try decoder.decode(from: encoded)
    }
    
    func test__command_step_with_single_command() {
        step = Pipeline.CommandStep(.command("echo \"Hello World\""))
        var output: Pipeline.CommandStep!
        XCTAssertNoThrow(output = try checkCodable(for: step))
        XCTAssertEqual(output, step)
    }
    
    func test__encoding__command_step_with_single_command() {
        step = Pipeline.CommandStep(.command("echo \"Hello World\""), label: nil)
        var encoded: String!
        XCTAssertNoThrow(encoded = try encoder.encode(step))
        let expected: String = """
        command: \'\"echo \"Hello World\"\"'

        """
        XCTAssertEqual(encoded, expected)
    }
}


final class StringQuotingTests: XCTestCase {
    
    func test__quote_string() {
        let expected: String = "\"hello world\""
        XCTAssertEqual("hello world".quoted(), expected)
    }
}
