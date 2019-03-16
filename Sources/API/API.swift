import Foundation
import ProcedureKit
import Utilities
import Domain

public enum API { /* Namespace */

    public typealias Key = String

    public static let hostname = "https://api.buildkite.com/"
    public static let version = "v2/"
    public static let server = URL(string: hostname)!.appendingPathComponent(version)

    public enum Builds { /* Namespace */
        public enum Filter {
            case state(Build.State)
            case commit(LongHash)
        }
    }


    internal static let queue = ProcedureQueue()
}
