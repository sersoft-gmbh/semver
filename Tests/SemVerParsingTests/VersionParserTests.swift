import XCTest
@testable import SemVerParsing

// FIXME: Remove this once Swift's tuple's are equatable or parameter packs cover this...
// Parameter packs don't seem to work in this case, since our lhs parameter is a predefined tuple in this case.
// And even the VariadicGenerics experimental flag doesn't cover concrete tuples just yet.
fileprivate func XCTAssertEqual<T1, T2, T3, T4, T5>(_ lhs: @autoclosure () -> (T1, T2, T3, T4, T5)?,
                                                    _ rhs: @autoclosure () -> (T1, T2, T3, T4, T5)?,
                                                    _ message: @autoclosure () -> String = "",
                                                    file: StaticString = #filePath,
                                                    line: UInt = #line)
where T1: Equatable, T2: Equatable, T3: Equatable, T4: Equatable, T5: Equatable
{
    let (lhsComps, rhsComps) = (lhs(), rhs())
    XCTAssertEqual(lhsComps?.0, rhsComps?.0, message(), file: file, line: line)
    XCTAssertEqual(lhsComps?.1, rhsComps?.1, message(), file: file, line: line)
    XCTAssertEqual(lhsComps?.2, rhsComps?.2, message(), file: file, line: line)
    XCTAssertEqual(lhsComps?.3, rhsComps?.3, message(), file: file, line: line)
    XCTAssertEqual(lhsComps?.4, rhsComps?.4, message(), file: file, line: line)
}

#if !canImport(Darwin)
protocol XCTActivity: NSObjectProtocol {
    var name: String { get }
}

open class XCTContext: NSObject {
    private final class _Activity: NSObject, XCTActivity {
        let name: String

        init(name: String) {
            self.name = name
        }
    }

    public class func runActivity<Result>(
        named name: String,
        block: (any XCTActivity) throws -> Result
    ) rethrows -> Result {
        try block(_Activity(name: name))
    }
}
#endif

final class VersionParserTests: XCTestCase {
    private typealias TestHandlerContext = (parser: (String) -> VersionParser.VersionComponents?, messagePrefix: String)
    private func performTests(with testHandler: (TestHandlerContext) throws -> ()) rethrows {
        try XCTContext.runActivity(named: "Legacy Parsing") {
            try testHandler(({
                guard !$0.isEmpty else { return nil }
                return VersionParser._parseLegacy($0)
            }, $0.name))
        }
        try XCTContext.runActivity(named: "Modern Parsing") {
            if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, macCatalyst 16, *) {
                try testHandler(({
                    guard !$0.isEmpty else { return nil }
                    return VersionParser._parseModern($0)
                }, $0.name))
            }
        }
        try XCTContext.runActivity(named: "Automatic Parsing") {
            try testHandler((VersionParser.parseString, $0.name))
        }
    }

    func testValidStrings() {
        performTests { context in
            let v1 = context.parser("1.2.3-beta+exp.test")
            let v2 = context.parser("1-beta")
            let v3 = context.parser("2+exp.test")
            let v4 = context.parser("2")
            let v5 = context.parser("2+abc-1")
            let v6 = context.parser("22.33+abc-1")
            let v7 = context.parser("1.1")
            let v8 = context.parser("3.0.0")
            let v9 = context.parser("1.2.3-alpha.1.-2+exp.test")

            XCTAssertNotNil(v1, context.messagePrefix)
            XCTAssertNotNil(v2, context.messagePrefix)
            XCTAssertNotNil(v3, context.messagePrefix)
            XCTAssertNotNil(v4, context.messagePrefix)
            XCTAssertNotNil(v5, context.messagePrefix)
            XCTAssertNotNil(v6, context.messagePrefix)
            XCTAssertNotNil(v7, context.messagePrefix)
            XCTAssertNotNil(v8, context.messagePrefix)
            XCTAssertNotNil(v9, context.messagePrefix)

            XCTAssertEqual(v1, (1, 2, 3, [.text("beta")], ["exp", "test"]), context.messagePrefix)
            XCTAssertEqual(v2, (1, 0, 0, [.text("beta")], []), context.messagePrefix)
            XCTAssertEqual(v3, (2, 0, 0, [], ["exp", "test"]), context.messagePrefix)
            XCTAssertEqual(v4, (2, 0, 0, [], []), context.messagePrefix)
            XCTAssertEqual(v5, (2, 0, 0, [], ["abc-1"]), context.messagePrefix)
            XCTAssertEqual(v6, (22, 33, 0, [], ["abc-1"]), context.messagePrefix)
            XCTAssertEqual(v7, (1, 1, 0, [], []), context.messagePrefix)
            XCTAssertEqual(v8, (3, 0, 0, [], []), context.messagePrefix)
            XCTAssertEqual(v9, (1, 2, 3, [.text("alpha"), .number(1), .number(-2)], ["exp", "test"]), context.messagePrefix)
        }
    }

    func testInvalidStrings() {
        performTests { context in
            XCTAssertNil(context.parser(""), context.messagePrefix)
            XCTAssertNil(context.parser("🥴"), context.messagePrefix)
            XCTAssertNil(context.parser("ABC"), context.messagePrefix)
            XCTAssertNil(context.parser("-1.2.0"), context.messagePrefix)
            XCTAssertNil(context.parser("1.2.3.4"), context.messagePrefix)
            XCTAssertNil(context.parser("1.2.3."), context.messagePrefix)
            XCTAssertNil(context.parser("1.2.3-beta."), context.messagePrefix)
            XCTAssertNil(context.parser("1.2.3+exp."), context.messagePrefix)
            XCTAssertNil(context.parser("\(UInt.max)"), context.messagePrefix)
        }
    }
}
