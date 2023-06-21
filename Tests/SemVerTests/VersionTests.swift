import XCTest
@testable import SemVer

final class VersionTests: XCTestCase {
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
        XCTAssertEqual(version.versionString(formattedWith: .includeMetadata), "1.2.3+exp.test")
    }
    
    func testVersionStringExcludingMetadata() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        XCTAssertEqual(version.versionString(formattedWith: .includePrerelease), "1.2.3-beta")
    }
    
    func testVersionStringWhenDroppingZeros() {
        let version1 = Version(major: 1, minor: 0, patch: 0)
        let version2 = Version(major: 2, minor: 0, patch: 1)
        let version3 = Version(major: 3, minor: 1, patch: 0)
        
        XCTAssertEqual(version1.versionString(formattedWith: [.fullVersion, .dropTrailingZeros]), "1")
        XCTAssertEqual(version1.versionString(formattedWith: [.fullVersion, .dropPatchIfZero]), "1.0")
        XCTAssertEqual(version1.versionString(formattedWith: [.fullVersion, .dropMinorIfZero]), "1.0.0")
        XCTAssertEqual(version2.versionString(formattedWith: [.fullVersion, .dropTrailingZeros]), "2.0.1")
        XCTAssertEqual(version2.versionString(formattedWith: [.fullVersion, .dropPatchIfZero]), "2.0.1")
        XCTAssertEqual(version2.versionString(formattedWith: [.fullVersion, .dropMinorIfZero]), "2.0.1")
        XCTAssertEqual(version3.versionString(formattedWith: [.fullVersion, .dropTrailingZeros]), "3.1")
        XCTAssertEqual(version3.versionString(formattedWith: [.fullVersion, .dropPatchIfZero]), "3.1")
        XCTAssertEqual(version3.versionString(formattedWith: [.fullVersion, .dropMinorIfZero]), "3.1.0")
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
        let v7 = Version(major: 1, minor: 1)
        let v8 = Version(major: 3)
        
        let v1FromString = Version(String(describing: v1))
        let v2FromString = Version(String(describing: v2))
        let v3FromString = Version(String(describing: v3))
        let v4FromString = Version(String(describing: v4))
        let v5FromString = Version(String(describing: v5))
        let v6FromString = Version(String(describing: v6))
        let v7FromString = Version(v7.versionString(formattedWith: .dropTrailingZeros))
        let v8FromString = Version(v8.versionString(formattedWith: .dropTrailingZeros))
        
        XCTAssertNotNil(v1FromString)
        XCTAssertNotNil(v2FromString)
        XCTAssertNotNil(v3FromString)
        XCTAssertNotNil(v4FromString)
        XCTAssertNotNil(v5FromString)
        XCTAssertNotNil(v6FromString)
        XCTAssertNotNil(v7FromString)
        XCTAssertNotNil(v8FromString)
        
        // We need to compare metadata manually here, since it's not considered in equality check
        XCTAssertEqual(v1, v1FromString)
        XCTAssertEqual(v1.metadata, v1FromString?.metadata)
        XCTAssertEqual(v2, v2FromString)
        XCTAssertEqual(v2.metadata, v2FromString?.metadata)
        XCTAssertEqual(v3, v3FromString)
        XCTAssertEqual(v3.metadata, v3FromString?.metadata)
        XCTAssertEqual(v4, v4FromString)
        XCTAssertEqual(v4.metadata, v4FromString?.metadata)
        XCTAssertEqual(v5, v5FromString)
        XCTAssertEqual(v5.metadata, v5FromString?.metadata)
        XCTAssertEqual(v6, v6FromString)
        XCTAssertEqual(v6.metadata, v6FromString?.metadata)
        XCTAssertEqual(v7, v7FromString)
        XCTAssertEqual(v7.metadata, v7FromString?.metadata)
        XCTAssertEqual(v8, v8FromString)
        XCTAssertEqual(v8.metadata, v8FromString?.metadata)
    }
    
    func testHashable() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
        let v3 = Version(major: 3)
        
        let v1Hash: Int = {
            var hasher = Hasher()
            hasher.combine(v1.major)
            hasher.combine(v1.minor)
            hasher.combine(v1.patch)
            hasher.combine(v1.prerelease)
            return hasher.finalize()
        }()
        let v2Hash: Int = {
            var hasher = Hasher()
            hasher.combine(v2.major)
            hasher.combine(v2.minor)
            hasher.combine(v2.patch)
            hasher.combine(v2.prerelease)
            return hasher.finalize()
        }()
        let v3Hash: Int = {
            var hasher = Hasher()
            hasher.combine(v3.major)
            hasher.combine(v3.minor)
            hasher.combine(v3.patch)
            hasher.combine(v3.prerelease)
            return hasher.finalize()
        }()
        
        XCTAssertEqual(v1.hashValue, v1Hash)
        XCTAssertEqual(v2.hashValue, v2Hash)
        XCTAssertEqual(v3.hashValue, v3Hash)
    }
    
    func testModifying() {
        var version = Version(major: 1)
        version.major = 2
        version.minor = 1
        version.patch = 3
        version.prerelease = "beta"
        version.metadata = ["yea", "testing", "rocks"]
        
        let expectedVersion = Version(major: 2, minor: 1, patch: 3, prerelease: "beta", metadata: "yea", "testing", "rocks")
        XCTAssertEqual(version, expectedVersion)
        XCTAssertEqual(version.versionString(formattedWith: .fullVersion),
                       expectedVersion.versionString(formattedWith: .fullVersion))
    }

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
    
    func testInvalidStrings() {
        XCTAssertNil(Version(""))
        XCTAssertNil(Version("1.2.3.4"))
        XCTAssertNil(Version("ABC"))
        XCTAssertNil(Version("-1.2.0"))
        XCTAssertNil(Version("🥴"))
    }

    func testCodable() throws {
        guard let version = Version("1.2.3") else {
            XCTFail("String literal init failed")
            return
        }
        XCTAssertNoThrow(try JSONEncoder().encode(version))
        let encoded = try JSONEncoder().encode(version)
        XCTAssertNotNil(encoded)
        let decoded = try JSONDecoder().decode(Version.self, from: encoded)
        XCTAssertEqual(decoded, version)
    }

    /*
    func testStringLiteralConversion() {
        XCTAssertEqual("1.2.3", Version(major: 1, minor: 2, patch: 3))
        XCTAssertEqual("1.2.3-rc1+exp-1.test", Version(major: 1, minor: 2, patch: 3, prerelease: "rc1", metadata: "exp-1", "test"))
        XCTAssertEqual("1.2.3+exp-1.test", Version(major: 1, minor: 2, patch: 3, metadata: "exp-1", "test"))
    }
    */
}
