import XCTest
import SemVerParsing

// FIXME: Remove this once Swift's tuple's are equatable or parameter packs cover this...
// Parameter packs don't seem to work in this case, since our lhs parameter is a predefined tuple in this case.
// And even the VariadicGenerics experimental flag doesn't cover concrete tuples just yet.
fileprivate func XCTAssertEqual<T1, T2, T3, T4, T5>(_ lhs: @autoclosure () -> (T1, T2, T3, T4, T5)?,
                                                    _ rhs: @autoclosure () -> (T1, T2, T3, T4, T5)?,
                                                    message: @autoclosure () -> String = "",
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

final class VersionParserTests: XCTestCase {
    func testParsingVersionStrings() {
        let v1 = VersionParser.parseString("1.2.3-beta+exp.test")
        let v2 = VersionParser.parseString("1-beta")
        let v3 = VersionParser.parseString("2+exp.test")
        let v4 = VersionParser.parseString("2")
        let v5 = VersionParser.parseString("2+abc-1")
        let v6 = VersionParser.parseString("22.33+abc-1")
        let v7 = VersionParser.parseString("1.1")
        let v8 = VersionParser.parseString("3.0.0")
        let v9 = VersionParser.parseString("1.2.3-alpha.1.-2+exp.test")

        XCTAssertNotNil(v1)
        XCTAssertNotNil(v2)
        XCTAssertNotNil(v3)
        XCTAssertNotNil(v4)
        XCTAssertNotNil(v5)
        XCTAssertNotNil(v6)
        XCTAssertNotNil(v7)
        XCTAssertNotNil(v8)
        XCTAssertNotNil(v9)

        XCTAssertEqual(v1, (1, 2, 3, [.text("beta")], ["exp", "test"]))
        XCTAssertEqual(v2, (1, 0, 0, [.text("beta")], []))
        XCTAssertEqual(v3, (2, 0, 0, [], ["exp", "test"]))
        XCTAssertEqual(v4, (2, 0, 0, [], []))
        XCTAssertEqual(v5, (2, 0, 0, [], ["abc-1"]))
        XCTAssertEqual(v6, (22, 33, 0, [], ["abc-1"]))
        XCTAssertEqual(v7, (1, 1, 0, [], []))
        XCTAssertEqual(v8, (3, 0, 0, [], []))
        XCTAssertEqual(v9, (1, 2, 3, [.text("alpha"), .number(1), .number(-2)], ["exp", "test"]))
    }

    func testInvalidStrings() {
        XCTAssertNil(VersionParser.parseString(""))
        XCTAssertNil(VersionParser.parseString("1.2.3.4"))
        XCTAssertNil(VersionParser.parseString("ABC"))
        XCTAssertNil(VersionParser.parseString("-1.2.0"))
        XCTAssertNil(VersionParser.parseString("🥴"))
    }
}
