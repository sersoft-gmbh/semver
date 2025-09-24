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

        @Test(arguments: [
            (strategy: Version.EncodingStrategy.components, expectedJson: #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#),
            (strategy: Version.EncodingStrategy.components(prereleaseAsString: false, metadataAsString: false), expectedJson: #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":["beta"]}"#),
            (strategy: Version.EncodingStrategy.components(prereleaseAsString: false, metadataAsString: true), expectedJson: #"{"major":1,"metadata":"exp.test","minor":2,"patch":3,"prerelease":["beta"]}"#),
            (strategy: Version.EncodingStrategy.components(prereleaseAsString: true, metadataAsString: true), expectedJson: #"{"major":1,"metadata":"exp.test","minor":2,"patch":3,"prerelease":"beta"}"#),
            (strategy: Version.EncodingStrategy.components(prereleaseAsString: true, metadataAsString: false), expectedJson: #"{"major":1,"metadata":["exp","test"],"minor":2,"patch":3,"prerelease":"beta"}"#),
        ])
        func encodingAsComponents(strategy: Version.EncodingStrategy, expectedJson: String) throws {
            let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .sortedKeys // stable comparison
            jsonEncoder.semverVersionEncodingStrategy = strategy
            let json = try jsonEncoder.encode(version)
            #expect(String(decoding: json, as: UTF8.self) == expectedJson)
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

            let versionDict = try jsonDecoder.decode(Dictionary<String, Version>.self,
                                                     from: Data(#"{"version":2}"#.utf8))
            let version = try #require(versionDict["version"])

            #expect(version.major == 2)
            #expect(version.minor == 0)
            #expect(version.patch == 0)
            #expect(version.prerelease.isEmpty)
            #expect(version.metadata.isEmpty)
        }

        @Test(arguments: [
            (json: #"{"major":-1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#, expectedDebugDescription: "Invalid major version component: -1", decodingStrategy: nil),
            (json: #"{"major":1,"minor":-2,"patch":3,"prerelease":"beta","metadata":["exp","test"]}"#, expectedDebugDescription: "Invalid minor version component: -2", decodingStrategy: nil),
            (json: #"{"major":1,"minor":2,"patch":-3,"prerelease":"beta","metadata":["exp","test"]}"#, expectedDebugDescription: "Invalid patch version component: -3", decodingStrategy: nil),
            (json: #"{"major":1,"minor":2,"patch":3,"prerelease":"bet@","metadata":["exp","test"]}"#, expectedDebugDescription: #"Invalid prerelease: ["bet@"]"#, decodingStrategy: nil),
            (json: #"{"major":1,"minor":2,"patch":3,"prerelease":"beta","metadata":["exp","t%st"]}"#, expectedDebugDescription: #"Invalid metadata: ["exp", "t%st"]"#, decodingStrategy: nil),
            (
                json: #"{"major":1,"minor":2,"patch":3,"prerelease":["bet@"],"metadata":["exp","test"]}"#,
                expectedDebugDescription: #"Invalid prerelease identifier: "bet@""#,
                decodingStrategy: Version.DecodingStrategy.components(prereleaseAsString: false, metadataAsString: false)
            ),
        ])
        func invalidDecoding(json: String, expectedDebugDescription: String, decodingStrategy: Version.DecodingStrategy?) throws {
            let jsonDecoder = JSONDecoder()
            if let decodingStrategy {
                jsonDecoder.semverVersionDecodingStrategy = decodingStrategy
            }

#if compiler(>=6.1)
            #expect(performing: { try jsonDecoder.decode(Version.self, from: Data(json.utf8)) },
                                throws: {
                guard case DecodingError.dataCorrupted(let context) = $0 else { return false }
                #expect(context.debugDescription == expectedDebugDescription)
                return true
            })
#else // The above would theoretically work on Swift 6.0 as well, but the compiler fails to compile it...
            do {
                _ = try jsonDecoder.decode(Version.self, from: Data(json.utf8))
                Issue.record("Expected error being thrown!")
            } catch DecodingError.dataCorrupted(let context) {
                #expect(context.debugDescription == expectedDebugDescription)
            }
#endif
        }
    }
}
