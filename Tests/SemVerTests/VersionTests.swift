import XCTest
@testable import SemVer

class VersionTests: XCTestCase {
    func testFullVersionString() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        XCTAssertEqual(version.versionString(), "1.2.3-beta+exp.test")
    }

    func testFullVersionStringWithSuffixWithoutData() {
        let version = Version(major: 1, minor: 2, patch: 3)
        XCTAssertEqual(version.versionString(), "1.2.3")
    }

    func testFullVersionStringWithoutPrereleaseDataWithMetadataData() {
        let version = Version(major: 1, minor: 2, patch: 3, metadata: "exp-1", "test")
        XCTAssertEqual(version.versionString(), "1.2.3+exp-1.test")
    }

    func testFullVersionStringWithPrereleaseDataWithoutMetadataData() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta-1")
        XCTAssertEqual(version.versionString(), "1.2.3-beta-1")
    }

    func testVersionStringExcludingPrerelease() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        XCTAssertEqual(version.versionString(includingPrerelease: false), "1.2.3+exp.test")
    }

    func testVersionStringExcludingMetadata() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        XCTAssertEqual(version.versionString(includingMetadata: false), "1.2.3-beta")
    }

    func testDescriptionIsEqualToFullVersionString() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        XCTAssertEqual(String(describing: version), version.versionString())
    }

    func testVersionEqualityWithBasicVersion() {
        let v1 = Version(major: 1, minor: 2, patch: 3)
        let v2 = Version(major: 1, minor: 2, patch: 3)
        let v3 = Version(major: 2, minor: 0, patch: 0)

        XCTAssertEqual(v1, v2)
        XCTAssertNotEqual(v1, v3)
        XCTAssertNotEqual(v2, v3)
    }

    func testVersionEqualityWithMetadataDifference() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
        let v3 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta2")

        XCTAssertEqual(v1, v2)
        XCTAssertNotEqual(v1, v3)
        XCTAssertNotEqual(v2, v3)
    }

    func testVersionComparisonWithBasicVersion() {
        let v0 = Version(major: 0, patch: 1)
        let v1 = Version(major: 1, minor: 2, patch: 3)
        let v2 = Version(major: 1, minor: 2, patch: 4)
        let v3 = Version(major: 2, minor: 0, patch: 0)
        let v3b = Version(major: 2, minor: 0, patch: 0, prerelease: "beta")
        let v3be = Version(major: 2, minor: 0, patch: 0, prerelease: "beta", metadata: "ext")
        let v4 = Version(major: 4)
        let v4b1 = Version(major: 4, prerelease: "beta1")
        let v4b2 = Version(major: 4, prerelease: "beta2")

        XCTAssertLessThan(v0, v1)
        XCTAssertLessThan(v1, v2)
        XCTAssertLessThan(v2, v3)
        XCTAssertLessThan(v3b, v3)
        XCTAssertLessThan(v3be, v3)
        XCTAssertLessThan(v4b1, v4b2)
        XCTAssertLessThan(v4b1, v4)
        XCTAssertLessThan(v4b2, v4)

        XCTAssertGreaterThan(v3, v0)
        XCTAssertGreaterThan(v3, v1)
        XCTAssertGreaterThan(v3, v2)
        XCTAssertGreaterThan(v3, v3b)
        XCTAssertGreaterThan(v3, v3be)
        XCTAssertGreaterThan(v4b2, v4b1)
        XCTAssertGreaterThan(v4, v4b1)
        XCTAssertGreaterThan(v4, v4b2)
    }

    func testLosslessStringConvertible() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, prerelease: "beta")
        let v3 = Version(major: 2, metadata: "exp", "test")
        let v4 = Version(major: 2)
        let v5 = Version(major: 2, metadata: "abc-1")
        let v6 = Version(major: 22, minor: 33, metadata: "abc-1")

        let v1FromString = Version(String(describing: v1))
        let v2FromString = Version(String(describing: v2))
        let v3FromString = Version(String(describing: v3))
        let v4FromString = Version(String(describing: v4))
        let v5FromString = Version(String(describing: v5))
        let v6FromString = Version(String(describing: v6))

        XCTAssertNotNil(v1FromString)
        XCTAssertNotNil(v2FromString)
        XCTAssertNotNil(v3FromString)
        XCTAssertNotNil(v4FromString)

        XCTAssertEqual(v1, v1FromString)
        XCTAssertEqual(v1.metadata, v1FromString?.metadata ?? [])
        XCTAssertEqual(v2, v2FromString)
        XCTAssertEqual(v2.metadata, v2FromString?.metadata ?? ["nope"])
        XCTAssertEqual(v3, v3FromString)
        XCTAssertEqual(v3.metadata, v3FromString?.metadata ?? [])
        XCTAssertEqual(v4, v4FromString)
        XCTAssertEqual(v4.metadata, v4FromString?.metadata ?? ["nope"])
        XCTAssertEqual(v5, v5FromString)
        XCTAssertEqual(v5.metadata, v5FromString?.metadata ?? [])
        XCTAssertEqual(v6, v6FromString)
        XCTAssertEqual(v6.metadata, v6FromString?.metadata ?? [])
    }

    func testHashable() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
        let v3 = Version(major: 3)

        var dict: Dictionary<Version, String> = [:]
        dict[v1] = "test1"
        dict[v2] = "test2" // this should replace test1
        dict[v3] = "test3"

        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict[v3], "test3")
        XCTAssertEqual(dict[v2], "test2")
        XCTAssertEqual(dict[v1], "test2")
    }

    static var allTests = [
        ("testFullVersionString", testFullVersionString),
        ("testFullVersionStringWithSuffixWithoutData", testFullVersionStringWithSuffixWithoutData),
        ("testFullVersionStringWithoutPrereleaseDataWithMetadataData", testFullVersionStringWithoutPrereleaseDataWithMetadataData),
        ("testFullVersionStringWithPrereleaseDataWithoutMetadataData", testFullVersionStringWithPrereleaseDataWithoutMetadataData),
        ("testVersionStringExcludingPrerelease", testVersionStringExcludingPrerelease),
        ("testVersionStringExcludingMetadata", testVersionStringExcludingMetadata),
        ("testDescriptionIsEqualToFullVersionString", testDescriptionIsEqualToFullVersionString),
        ("testVersionEqualityWithBasicVersion", testVersionEqualityWithBasicVersion),
        ("testVersionEqualityWithMetadataDifference", testVersionEqualityWithMetadataDifference),
        ("testVersionComparisonWithBasicVersion", testVersionComparisonWithBasicVersion),
        ("testLosslessStringConvertible", testLosslessStringConvertible),
        ("testHashable", testHashable),
    ]
}
