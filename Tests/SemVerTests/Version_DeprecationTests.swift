import XCTest
import SemVer

@available(*, deprecated, message: "This test case only tests deprecated APIs.")
final class Version_DeprecationTests: XCTestCase {
    func testOldPrereleaseInitializers() {
        let v1 = Version(major: 1, prerelease: "abc.def")
        let v2 = Version(major: 1, prerelease: "abc.def", metadata: "abc")
        XCTAssertEqual(v1, Version(major: 1, preReleaseIdentifiers: "abc", "def"))
        XCTAssertEqual(v2, Version(major: 1, preReleaseIdentifiers: "abc", "def", metadata: "abc"))
    }

    func testOldPrerelease() {
        var v1 = Version(major: 1, preReleaseIdentifiers: "abc", "def")
        XCTAssertEqual(v1.prerelease, "abc.def")
        v1.prerelease = "abc.xyz"
        XCTAssertEqual(v1.preReleaseIdentifiers, ["abc", "xyz"])
        XCTAssertEqual(v1.prerelease, "abc.xyz")
    }
}
