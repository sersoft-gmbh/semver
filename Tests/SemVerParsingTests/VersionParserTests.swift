import Testing
@testable import SemVerParsing

@Suite
struct VersionParserTests {
    private static let inputsToResults: Dictionary<String, VersionParser.VersionComponents?> = [
        // valid
        "1.2.3-beta+exp.test": (1, 2, 3, [.text("beta")], ["exp", "test"]),
        "1-beta": (1, 0, 0, [.text("beta")], []),
        "2+exp.test": (2, 0, 0, [], ["exp", "test"]),
        "2": (2, 0, 0, [], []),
        "2+abc-1": (2, 0, 0, [], ["abc-1"]),
        "22.33+abc-1": (22, 33, 0, [], ["abc-1"]),
        "1.1": (1, 1, 0, [], []),
        "3.0.0": (3, 0, 0, [], []),
        "1.2.3-alpha.1.-2+exp.test": (1, 2, 3, [.text("alpha"), .number(1), .number(-2)], ["exp", "test"]),
        // invalid
        "🥴": nil,
        "ABC": nil,
        "-1.2.0": nil,
        "1.2.3.4": nil,
        "1.2.3.": nil,
        "1.2.3-beta.": nil,
        "1.2.3+exp.": nil,
        "\(UInt.max)": nil,
    ]
#if compiler(>=6.1)
    private static var testArgs: some Collection<(String, VersionParser.VersionComponents?)> & Sendable {
        inputsToResults.lazy.map { ($0.key, $0.value) }
    }
#else
    private static var testArgs: Array<(String, VersionParser.VersionComponents?)> {
        inputsToResults.map { ($0.key, $0.value) }
    }
#endif

    @Test(arguments: testArgs)
    func legacyParsing(input: String, output: VersionParser.VersionComponents?) throws {
        if let output {
            #expect(try #require(VersionParser._parseLegacy(input)) == output)
        } else {
            #expect(VersionParser._parseLegacy(input) == nil)
        }
    }

    @Test(arguments: testArgs)
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, macCatalyst 16, *)
    func modernParsing(input: String, output: VersionParser.VersionComponents?) throws {
        if let output {
            #expect(try #require(VersionParser._parseModern(input)) == output)
        } else {
            #expect(VersionParser._parseModern(input) == nil)
        }
    }

    // The automatic parser also accepts empty strings, returning nil
    @Test(arguments: Array(testArgs) + CollectionOfOne(("", nil)))
    func automaticParsing(input: String, output: VersionParser.VersionComponents?) throws {
        if let output {
            #expect(try #require(VersionParser.parseString(input)) == output)
        } else {
            #expect(VersionParser.parseString(input) == nil)
        }
    }
}
