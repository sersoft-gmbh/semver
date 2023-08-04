//
//  Version_ComparableTests.swift
//  
//
//  Created by Crazy凡 on 2023/8/4.
//

import XCTest
@testable import SemVer

final class Version_ComparableTests: XCTestCase {
    func testComparable() {
        let v123 = Version("1.2.3")
        let v124 = Version("1.2.4")

        let v123Alpha = Version("1.2.3-alpha")
        let v123Beta = Version("1.2.3-beta")

        XCTAssertNotNil(v123)
        XCTAssertNotNil(v124)
        XCTAssertNotNil(v123Alpha)
        XCTAssertNotNil(v123Beta)

        XCTAssertEqual(v123, Version(major: 1, minor: 2, patch: 3))
        XCTAssertEqual(v123Alpha, Version(major: 1, minor: 2, patch: 3, prerelease: "alpha"))
        XCTAssertEqual(v123Beta, Version(major: 1, minor: 2, patch: 3, prerelease: "beta"))

        guard let v123, let v124, let v123Alpha, let v123Beta else {
            return
        }

        XCTAssertFalse(v123 < v123)
        XCTAssertFalse(v123Alpha < v123Alpha)
        XCTAssertFalse(v123Beta < v123Beta)

        XCTAssertFalse(v123 > v123)
        XCTAssertFalse(v123Alpha > v123Alpha)
        XCTAssertFalse(v123Beta > v123Beta)

        XCTAssertTrue(v123Alpha < v123)
        XCTAssertTrue(v123Alpha < v123Beta)
        XCTAssertTrue(v123Alpha < v124)
        XCTAssertTrue(v123Beta < v123)
        XCTAssertTrue(v123Beta < v124)
        XCTAssertTrue(v123 < v124)

        XCTAssertFalse(v123 < v123Alpha)
        XCTAssertFalse(v123Beta < v123Alpha)
        XCTAssertFalse(v124 < v123Alpha)
        XCTAssertFalse(v123 < v123Beta)
        XCTAssertFalse(v124 < v123Beta)
        XCTAssertFalse(v124 < v123)

        XCTAssertFalse(v123Alpha > v123)
        XCTAssertFalse(v123Alpha > v123Beta)
        XCTAssertFalse(v123Alpha > v124)
        XCTAssertFalse(v123Beta > v123)
        XCTAssertFalse(v123Beta > v124)
        XCTAssertFalse(v123 > v124)

        XCTAssertTrue(v123 > v123Alpha)
        XCTAssertTrue(v123Beta > v123Alpha)
        XCTAssertTrue(v124 > v123Alpha)
        XCTAssertTrue(v123 > v123Beta)
        XCTAssertTrue(v124 > v123Beta)
        XCTAssertTrue(v124 > v123)
    }
}
