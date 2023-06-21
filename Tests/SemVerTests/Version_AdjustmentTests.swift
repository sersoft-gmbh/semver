import XCTest
import SemVer

final class Version_AdjustmentTests: XCTestCase {
    func testNextVersion() {
        let metadata = ["abc", "def"]
        let version = Version(major: 1, minor: 2, patch: 3, metadata: metadata)

        XCTAssertEqual(version.next(.major), Version(major: 2))
        XCTAssertEqual(version.next(.minor), Version(major: 1, minor: 3))
        XCTAssertEqual(version.next(.patch), Version(major: 1, minor: 2, patch: 4))
        XCTAssertTrue(version.next(.major).metadata.isEmpty)
        XCTAssertTrue(version.next(.minor).metadata.isEmpty)
        XCTAssertTrue(version.next(.patch).metadata.isEmpty)
        XCTAssertEqual(version.next(.major, keepingMetadata: true), Version(major: 2))
        XCTAssertEqual(version.next(.minor, keepingMetadata: true), Version(major: 1, minor: 3))
        XCTAssertEqual(version.next(.patch, keepingMetadata: true), Version(major: 1, minor: 2, patch: 4))
        XCTAssertEqual(version.next(.major, keepingMetadata: true).metadata, metadata)
        XCTAssertEqual(version.next(.minor, keepingMetadata: true).metadata, metadata)
        XCTAssertEqual(version.next(.patch, keepingMetadata: true).metadata, metadata)
    }

    func testVersionIncrease() {
        let metadata = ["abc", "def"]
        let version = Version(major: 1, minor: 2, patch: 3, metadata: metadata)

        var mutatingVersion = version
        mutatingVersion.increase(.major)
        XCTAssertEqual(mutatingVersion, Version(major: 2))
        XCTAssertTrue(mutatingVersion.metadata.isEmpty)
        mutatingVersion = version
        mutatingVersion.increase(.minor)
        XCTAssertEqual(mutatingVersion, Version(major: 1, minor: 3))
        XCTAssertTrue(mutatingVersion.metadata.isEmpty)

        mutatingVersion = version
        mutatingVersion.increase(.patch)
        XCTAssertEqual(mutatingVersion, Version(major: 1, minor: 2, patch: 4))
        XCTAssertTrue(mutatingVersion.metadata.isEmpty)

        mutatingVersion = version
        mutatingVersion.increase(.major, keepingMetadata: true)
        XCTAssertEqual(mutatingVersion, Version(major: 2))
        XCTAssertEqual(mutatingVersion.metadata, metadata)

        mutatingVersion = version
        mutatingVersion.increase(.minor, keepingMetadata: true)
        XCTAssertEqual(mutatingVersion, Version(major: 1, minor: 3))
        XCTAssertEqual(mutatingVersion.metadata, metadata)

        mutatingVersion = version
        mutatingVersion.increase(.patch, keepingMetadata: true)
        XCTAssertEqual(mutatingVersion, Version(major: 1, minor: 2, patch: 4))
        XCTAssertEqual(mutatingVersion.metadata, metadata)
    }
}
