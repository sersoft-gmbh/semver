import Testing
import Foundation
import SemVer

fileprivate extension Version.EncodingStrategy {
    func isComponents(prereleaseAsString expectedPreReleaseIdentifiersAsString: Bool,
                      metadataAsString expectedMetadataAsString: Bool) -> Bool {
        switch self {
        case .components(let prereleaseAsString, let metadataAsString):
            return prereleaseAsString == expectedPreReleaseIdentifiersAsString && metadataAsString == expectedMetadataAsString
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
    func isComponents(prereleaseAsString expectedPreReleaseIdentifiersAsString: Bool,
                      metadataAsString expectedMetadataAsString: Bool) -> Bool {
        switch self {
        case .components(let prereleaseAsString, let metadataAsString):
            return prereleaseAsString == expectedPreReleaseIdentifiersAsString && metadataAsString == expectedMetadataAsString
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

extension VersionTests {
    @Suite
    struct CodableTests {
        @Test
        func foundationCodersVersionStrategyExtensions() {
            let jsonEncoder = JSONEncoder()
            let jsonDecoder = JSONDecoder()
            let plistEncoder = PropertyListEncoder()
            let plistDecoder = PropertyListDecoder()

            #expect(jsonEncoder.semverVersionEncodingStrategy.isComponents(prereleaseAsString: true, metadataAsString: false))
            #expect(jsonDecoder.semverVersionDecodingStrategy.isComponents(prereleaseAsString: true, metadataAsString: false))
            #expect(plistEncoder.semverVersionEncodingStrategy.isComponents(prereleaseAsString: true, metadataAsString: false))
            #expect(plistDecoder.semverVersionDecodingStrategy.isComponents(prereleaseAsString: true, metadataAsString: false))

            jsonEncoder.semverVersionEncodingStrategy = .string
            jsonDecoder.semverVersionDecodingStrategy = .string
            plistEncoder.semverVersionEncodingStrategy = .string
            plistDecoder.semverVersionDecodingStrategy = .string

            #expect(jsonEncoder.semverVersionEncodingStrategy.isString(with: .fullVersion))
            #expect(jsonDecoder.semverVersionDecodingStrategy.isString)
            #expect(plistEncoder.semverVersionEncodingStrategy.isString(with: .fullVersion))
            #expect(plistDecoder.semverVersionDecodingStrategy.isString)

        }

        @Test
        func encodingWithDefaultStrategy() throws {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .sortedKeys // stable comparison

            let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

            let json = try jsonEncoder.encode(version)

            #expect(String(decoding: json, as: UTF8.self)
                    ==
                    #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#)
        }

        @Test
        func decodingWithDefaultStrategy() throws {
            let jsonDecoder = JSONDecoder()

            let fullJson = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
            let minJson = Data(#"{"major":1}"#.utf8)

            let fullVersion = try jsonDecoder.decode(Version.self, from: fullJson)
            let minVersion = try jsonDecoder.decode(Version.self, from: minJson)

            #expect(fullVersion.major == 1)
            #expect(fullVersion.minor == 2)
            #expect(fullVersion.patch == 3)
            #expect(fullVersion.prerelease == ["beta"])
            #expect(fullVersion.metadata == ["exp", "test"])

            #expect(minVersion.major == 1)
            #expect(minVersion.minor == 0)
            #expect(minVersion.patch == 0)
            #expect(minVersion.prerelease.isEmpty)
            #expect(minVersion.metadata.isEmpty)
        }

        @Test
        func encodingAsComponents() throws {
            let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .sortedKeys // stable comparison

            jsonEncoder.semverVersionEncodingStrategy = .components
            let json1 = try jsonEncoder.encode(version)

            jsonEncoder.semverVersionEncodingStrategy = .components(prereleaseAsString: false, metadataAsString: false)
            let json2 = try jsonEncoder.encode(version)

            jsonEncoder.semverVersionEncodingStrategy = .components(prereleaseAsString: false, metadataAsString: true)
            let json3 = try jsonEncoder.encode(version)

            jsonEncoder.semverVersionEncodingStrategy = .components(prereleaseAsString: true, metadataAsString: true)
            let json4 = try jsonEncoder.encode(version)

            jsonEncoder.semverVersionEncodingStrategy = .components(prereleaseAsString: true, metadataAsString: false)
            let json5 = try jsonEncoder.encode(version)

            #expect(String(decoding: json1, as: UTF8.self)
                    ==
                    #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#)
            #expect(String(decoding: json2, as: UTF8.self)
                    ==
                    #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":["beta"]}"#)
            #expect(String(decoding: json3, as: UTF8.self)
                    ==
                    #"{"major":1,"metadata":"exp.test","minor":2,"patch":3,"prerelease":["beta"]}"#)
            #expect(String(decoding: json4, as: UTF8.self)
                    ==
                    #"{"major":1,"metadata":"exp.test","minor":2,"patch":3,"prerelease":"beta"}"#)
            #expect(String(decoding: json5, as: UTF8.self)
                    ==
                    #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#)
        }

        @Test
        func decodingAsComponents() throws {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.semverVersionDecodingStrategy = .components

            let fullJson = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
            let minJson = Data(#"{"major":1}"#.utf8)

            let fullVersion = try jsonDecoder.decode(Version.self, from: fullJson)
            let minVersion = try jsonDecoder.decode(Version.self, from: minJson)

            #expect(fullVersion.major == 1)
            #expect(fullVersion.minor == 2)
            #expect(fullVersion.patch == 3)
            #expect(fullVersion.prerelease == ["beta"])
            #expect(fullVersion.metadata == ["exp", "test"])

            #expect(minVersion.major == 1)
            #expect(minVersion.minor == 0)
            #expect(minVersion.patch == 0)
            #expect(minVersion.prerelease.isEmpty)
            #expect(minVersion.metadata.isEmpty)
        }

        @Test
        func decodingAsComponentsWithNonStrings() throws {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.semverVersionDecodingStrategy = .components(prereleaseAsString: false, metadataAsString: false)

            let fullJson = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":["beta"],"metadata":["exp","test"]}"#.utf8)
            let minJson = Data(#"{"major":1}"#.utf8)

            let fullVersion = try jsonDecoder.decode(Version.self, from: fullJson)
            let minVersion = try jsonDecoder.decode(Version.self, from: minJson)

            #expect(fullVersion.major == 1)
            #expect(fullVersion.minor == 2)
            #expect(fullVersion.patch == 3)
            #expect(fullVersion.prerelease == ["beta"])
            #expect(fullVersion.metadata == ["exp", "test"])

            #expect(minVersion.major == 1)
            #expect(minVersion.minor == 0)
            #expect(minVersion.patch == 0)
            #expect(minVersion.prerelease.isEmpty)
            #expect(minVersion.metadata.isEmpty)
        }

        @Test
        func decodingAsComponentsWithAllStrings() throws {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.semverVersionDecodingStrategy = .components(prereleaseAsString: true, metadataAsString: true)

            let fullJson = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":"exp.test"}"#.utf8)
            let minJson = Data(#"{"major":1}"#.utf8)

            let fullVersion = try jsonDecoder.decode(Version.self, from: fullJson)
            let minVersion = try jsonDecoder.decode(Version.self, from: minJson)

            #expect(fullVersion.major == 1)
            #expect(fullVersion.minor == 2)
            #expect(fullVersion.patch == 3)
            #expect(fullVersion.prerelease == ["beta"])
            #expect(fullVersion.metadata == ["exp", "test"])

            #expect(minVersion.major == 1)
            #expect(minVersion.minor == 0)
            #expect(minVersion.patch == 0)
            #expect(minVersion.prerelease.isEmpty)
            #expect(minVersion.metadata.isEmpty)
        }

        @Test
        func encodingAsString() throws {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .sortedKeys // stable comparison
            jsonEncoder.semverVersionEncodingStrategy = .string(.fullVersion)

            let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

            let json = try jsonEncoder.encode(["version": version])

            #expect(String(decoding: json, as: UTF8.self) == #"{"version":"1.2.3-beta+exp.test"}"#)
        }

        @Test
        func decodingAsString() throws {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.semverVersionDecodingStrategy = .string

            let validJson = Data(#"{"version":"1.2.3-beta+exp.test"}"#.utf8)
            let invalidJSON = Data(#"{"version":"not-valid"}"#.utf8)

            let versionDict = try jsonDecoder.decode(Dictionary<String, Version>.self, from: validJson)
            let version = try #require(versionDict["version"])

            #expect(version.major == 1)
            #expect(version.minor == 2)
            #expect(version.patch == 3)
            #expect(version.prerelease == ["beta"])
            #expect(version.metadata == ["exp", "test"])

            #expect(throws: DecodingError.self) {
                try jsonDecoder.decode(Dictionary<String, Version>.self, from: invalidJSON)
            }
        }

        @Test
        func customEncoding() throws {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .sortedKeys // stable comparison
            jsonEncoder.semverVersionEncodingStrategy = .custom {
                var container = $1.singleValueContainer()
                try container.encode("\($0.major)-\($0.minor)-\($0.patch)-\($0.prerelease.lazy.map(\.string).joined(separator: "&"))-\($0.metadata.joined(separator: "#"))")
            }

            let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")

            let json = try jsonEncoder.encode(["version": version])

            #expect(String(decoding: json, as: UTF8.self) == #"{"version":"1-2-3-beta-exp#test"}"#)
        }

        @Test
        func customDecoding() throws {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.semverVersionDecodingStrategy = .custom {
                let major = try $0.singleValueContainer().decode(Int.self)
                return .init(major: major)
            }

            let json = Data(#"{"version":2}"#.utf8)
            let versionDict = try jsonDecoder.decode(Dictionary<String, Version>.self, from: json)
            let version = try #require(versionDict["version"])

            #expect(version.major == 2)
            #expect(version.minor == 0)
            #expect(version.patch == 0)
            #expect(version.prerelease.isEmpty)
            #expect(version.metadata.isEmpty)
        }

        @Test
        func invalidDecoding() throws {
            let invalidJSON1 = Data(#"{"major":-1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
            let invalidJSON2 = Data(#"{"major":1,"minor":-2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
            let invalidJSON3 = Data(#"{"major":1,"minor":2,"patch":-3,"prerelease":"beta","metadata":["exp","test"]}"#.utf8)
            let invalidJSON4 = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"bet@","metadata":["exp","test"]}"#.utf8)
            let invalidJSON5 = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","t%st"]}"#.utf8)
            let invalidJSON6 = Data(#"{"major":1,"minor":2,"patch":3,"prerelease":["bet@"],"metadata":["exp","test"]}"#.utf8)
            let jsonDecoder = JSONDecoder()

            // TODO: Once we drop support for Swift 6.0, we can re-work these to use the returned error from `#expect(throws:)`

            #expect(throws: DecodingError.self) {
                do {
                    _ = try jsonDecoder.decode(Version.self, from: invalidJSON1)
                } catch DecodingError.dataCorrupted(let context) {
                    #expect(context.debugDescription == "Invalid major version component: -1")
                    throw DecodingError.dataCorrupted(context)
                } catch let decodingError as DecodingError {
                    Issue.record("Invalid error: \(decodingError)")
                    throw decodingError
                }
            }
            #expect(throws: DecodingError.self) {
                do {
                    _ = try jsonDecoder.decode(Version.self, from: invalidJSON2)
                } catch DecodingError.dataCorrupted(let context) {
                    #expect(context.debugDescription == "Invalid minor version component: -2")
                    throw DecodingError.dataCorrupted(context)
                } catch let decodingError as DecodingError {
                    Issue.record("Invalid error: \(decodingError)")
                    throw decodingError
                }
            }
            #expect(throws: DecodingError.self) {
                do {
                    _ = try jsonDecoder.decode(Version.self, from: invalidJSON3)
                } catch DecodingError.dataCorrupted(let context) {
                    #expect(context.debugDescription == "Invalid patch version component: -3")
                    throw DecodingError.dataCorrupted(context)
                } catch let decodingError as DecodingError {
                    Issue.record("Invalid error: \(decodingError)")
                    throw decodingError
                }
            }
            #expect(throws: DecodingError.self) {
                do {
                    _ = try jsonDecoder.decode(Version.self, from: invalidJSON4)
                } catch DecodingError.dataCorrupted(let context) {
                    #expect(context.debugDescription == #"Invalid prerelease: ["bet@"]"#)
                    throw DecodingError.dataCorrupted(context)
                } catch let decodingError as DecodingError {
                    Issue.record("Invalid error: \(decodingError)")
                    throw decodingError
                }
            }
            #expect(throws: DecodingError.self) {
                do {
                    _ = try jsonDecoder.decode(Version.self, from: invalidJSON5)
                } catch DecodingError.dataCorrupted(let context) {
                    #expect(context.debugDescription == #"Invalid metadata: ["exp", "t%st"]"#)
                    throw DecodingError.dataCorrupted(context)
                } catch let decodingError as DecodingError {
                    Issue.record("Invalid error: \(decodingError)")
                    throw decodingError
                }
            }
            jsonDecoder.semverVersionDecodingStrategy = .components(prereleaseAsString: false, metadataAsString: false)
            #expect(throws: DecodingError.self) {
                do {
                    _ = try jsonDecoder.decode(Version.self, from: invalidJSON6)
                } catch DecodingError.dataCorrupted(let context) {
                    #expect(context.debugDescription == #"Invalid prerelease identifier: "bet@""#)
                    throw DecodingError.dataCorrupted(context)
                } catch let decodingError as DecodingError {
                    Issue.record("Invalid error: \(decodingError)")
                    throw decodingError
                }
            }
        }
    }
}
