import XCTest
import Foundation
import SemVer

fileprivate extension Version.EncodingStrategy {
    var isComponents: Bool {
        switch self {
        case .components: return true
        default: return false
        }
    }

    func isString(with expectedOptions: Version.FormattingOptions) -> Bool {
        switch self {
        case .string(let options): return expectedOptions == options
        default: return false
        }
    }
}

fileprivate extension Version.DecodingStrategy {
    var isComponents: Bool {
        switch self {
        case .components: return true
        default: return false
        }
    }

    var isString: Bool {
        switch self {
        case .string: return true
        default: return false
        }
    }
}

final class Version_CodableTests: XCTestCase {
    func testFoundationCodersVersionStrategyExtensions() {
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        let plistEncoder = PropertyListEncoder()
        let plistDecoder = PropertyListDecoder()

        XCTAssertTrue(jsonEncoder.semverVersionEncodingStrategy.isComponents)
        XCTAssertTrue(jsonDecoder.semverVersionDecodingStrategy.isComponents)
        XCTAssertTrue(plistEncoder.semverVersionEncodingStrategy.isComponents)
        XCTAssertTrue(plistDecoder.semverVersionDecodingStrategy.isComponents)

        jsonEncoder.semverVersionEncodingStrategy = .string
        jsonDecoder.semverVersionDecodingStrategy = .string
        plistEncoder.semverVersionEncodingStrategy = .string
        plistDecoder.semverVersionDecodingStrategy = .string

        XCTAssertTrue(jsonEncoder.semverVersionEncodingStrategy.isString(with: .fullVersion))
        XCTAssertTrue(jsonDecoder.semverVersionDecodingStrategy.isString)
        XCTAssertTrue(plistEncoder.semverVersionEncodingStrategy.isString(with: .fullVersion))
        XCTAssertTrue(plistDecoder.semverVersionDecodingStrategy.isString)

    }

    func testEncodingWithDefaultStrategy() throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys // stable comparison

        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

        let json = try jsonEncoder.encode(version)

        XCTAssertEqual(String(decoding: json, as: UTF8.self),
                       #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#)
    }

    func testDecodingWithDefaultStrategy() throws {
        let jsonDecoder = JSONDecoder()

        let fullJson = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
        let minJson = Data(#"{"major":1}"#.utf8)

        let fullVersion = try jsonDecoder.decode(Version.self, from: fullJson)
        let minVersion = try jsonDecoder.decode(Version.self, from: minJson)

        XCTAssertEqual(fullVersion.major, 1)
        XCTAssertEqual(fullVersion.minor, 2)
        XCTAssertEqual(fullVersion.patch, 3)
        XCTAssertEqual(fullVersion.prerelease, "beta")
        XCTAssertEqual(fullVersion.metadata, ["exp", "test"])

        XCTAssertEqual(minVersion.major, 1)
        XCTAssertEqual(minVersion.minor, 0)
        XCTAssertEqual(minVersion.patch, 0)
        XCTAssertTrue(minVersion.prerelease.isEmpty)
        XCTAssertTrue(minVersion.metadata.isEmpty)
    }

    func testEncodingAsComponents() throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys // stable comparison
        jsonEncoder.semverVersionEncodingStrategy = .components

        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

        let json = try jsonEncoder.encode(version)

        XCTAssertEqual(String(decoding: json, as: UTF8.self),
                       #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#)
    }

    func testDecodingAsComponents() throws {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.semverVersionDecodingStrategy = .components

        let fullJson = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
        let minJson = Data(#"{"major":1}"#.utf8)

        let fullVersion = try jsonDecoder.decode(Version.self, from: fullJson)
        let minVersion = try jsonDecoder.decode(Version.self, from: minJson)

        XCTAssertEqual(fullVersion.major, 1)
        XCTAssertEqual(fullVersion.minor, 2)
        XCTAssertEqual(fullVersion.patch, 3)
        XCTAssertEqual(fullVersion.prerelease, "beta")
        XCTAssertEqual(fullVersion.metadata, ["exp", "test"])

        XCTAssertEqual(minVersion.major, 1)
        XCTAssertEqual(minVersion.minor, 0)
        XCTAssertEqual(minVersion.patch, 0)
        XCTAssertTrue(minVersion.prerelease.isEmpty)
        XCTAssertTrue(minVersion.metadata.isEmpty)
    }

    func testEncodingAsString() throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys // stable comparison
        jsonEncoder.semverVersionEncodingStrategy = .string(.fullVersion)

        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

        let json = try jsonEncoder.encode(["version": version])

        XCTAssertEqual(String(decoding: json, as: UTF8.self), #"{"version":"1.2.3-beta+exp.test"}"#)
    }

    func testDecodingAsString() throws {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.semverVersionDecodingStrategy = .string

        let validJson = Data(#"{"version":"1.2.3-beta+exp.test"}"#.utf8)
        let invalidJSON = Data(#"{"version":"not-valid"}"#.utf8)

        let versionDict = try jsonDecoder.decode(Dictionary<String, Version>.self, from: validJson)
        let version = try XCTUnwrap(versionDict["version"])

        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 2)
        XCTAssertEqual(version.patch, 3)
        XCTAssertEqual(version.prerelease, "beta")
        XCTAssertEqual(version.metadata, ["exp", "test"])

        XCTAssertThrowsError(try jsonDecoder.decode(Dictionary<String, Version>.self, from: invalidJSON))
    }

    func testCustomEncoding() throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys // stable comparison
        jsonEncoder.semverVersionEncodingStrategy = .custom {
            var container = $1.singleValueContainer()
            try container.encode("\($0.major)-\($0.minor)-\($0.patch)-\($0.prerelease)-\($0.metadata.joined(separator: "#"))")
        }

        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

        let json = try jsonEncoder.encode(["version": version])

        XCTAssertEqual(String(decoding: json, as: UTF8.self), #"{"version":"1-2-3-beta-exp#test"}"#)
    }

    func testCustomDecoding() throws {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.semverVersionDecodingStrategy = .custom {
            let major = try $0.singleValueContainer().decode(Int.self)
            return .init(major: major)
        }

        let json = Data(#"{"version":2}"#.utf8)
        let versionDict = try jsonDecoder.decode(Dictionary<String, Version>.self, from: json)
        let version = try XCTUnwrap(versionDict["version"])

        XCTAssertEqual(version.major, 2)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        XCTAssertTrue(version.prerelease.isEmpty)
        XCTAssertTrue(version.metadata.isEmpty)
    }
}
