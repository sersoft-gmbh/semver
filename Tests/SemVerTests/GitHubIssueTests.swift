import XCTest
import SemVer

final class GitHubIssueTests: XCTestCase {
    func testGH107() throws {
        let _version = Version("1.0.0-beta.11")
        XCTAssertNotNil(_version)
        let version = try XCTUnwrap(_version)
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        XCTAssertEqual(version.prerelease, ["beta", "11"])
    }
}
