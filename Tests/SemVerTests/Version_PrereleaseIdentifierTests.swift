import XCTest
@testable import SemVer

final class Version_PrereleaseIdentifierTests: XCTestCase {
    func testDescription() {
        let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
        let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

        XCTAssertEqual(prereleaseIdentifierText.description, prereleaseIdentifierText.string)
        XCTAssertEqual(prereleaseIdentifierNumber.description, prereleaseIdentifierNumber.string)
    }

    func testDebugDescription() {
        let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
        let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

        XCTAssertEqual(prereleaseIdentifierText.debugDescription, "text(\(prereleaseIdentifierText.string))")
        XCTAssertEqual(prereleaseIdentifierNumber.debugDescription, "number(\(prereleaseIdentifierNumber.string))")
    }

    func testString() {
        let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
        let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

        XCTAssertEqual(prereleaseIdentifierText.string, "test")
        XCTAssertEqual(prereleaseIdentifierNumber.string, "1")
    }

    func testNumber() {
        let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
        let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

        XCTAssertNil(prereleaseIdentifierText.number)
        XCTAssertEqual(prereleaseIdentifierNumber.number, 1)
    }

    func testCreation() {
        let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
        let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)
        let prereleaseIdentifierNumberFromText = Version.PrereleaseIdentifier.string("42")
        let prereleaseIdentifierUncheckedText = Version.PrereleaseIdentifier(unchecked: "abc")

        XCTAssertEqual(prereleaseIdentifierText._storage, .text("test"))
        XCTAssertEqual(prereleaseIdentifierNumber._storage, .number(1))
        XCTAssertEqual(prereleaseIdentifierNumberFromText._storage, .number(42))
        XCTAssertEqual(prereleaseIdentifierUncheckedText._storage, .text("abc"))
    }

    func testCreationFromLiterals() {
        let prereleaseIdentifierText: Version.PrereleaseIdentifier = "test"
        let prereleaseIdentifierNumber: Version.PrereleaseIdentifier = 1
        let prereleaseIdentifierNumberFromText: Version.PrereleaseIdentifier = "42"

        XCTAssertEqual(prereleaseIdentifierText._storage, .text("test"))
        XCTAssertEqual(prereleaseIdentifierNumber._storage, .number(1))
        XCTAssertEqual(prereleaseIdentifierNumberFromText._storage, .number(42))
    }

    func testComparision() {
        let textABC: Version.PrereleaseIdentifier = "abc"
        let textDEF: Version.PrereleaseIdentifier = "def"
        let num42: Version.PrereleaseIdentifier = 42
        let num142: Version.PrereleaseIdentifier = 142

        XCTAssertTrue(textABC < textDEF)
        XCTAssertLessThan(textABC, textDEF)

        XCTAssertTrue(num42 < num142)
        XCTAssertLessThan(num42, num142)

        XCTAssertTrue(num42 < textABC)
        XCTAssertTrue(num42 < textDEF)
        XCTAssertTrue(num142 < textABC)
        XCTAssertTrue(num142 < textDEF)
        XCTAssertLessThan(num42, textABC)
        XCTAssertLessThan(num42, textDEF)
        XCTAssertLessThan(num142, textABC)
        XCTAssertLessThan(num142, textDEF)

        XCTAssertFalse(textABC < num42)
        XCTAssertFalse(textDEF < num42)
        XCTAssertFalse(textABC < num142)
        XCTAssertFalse(textDEF < num142)
        XCTAssertGreaterThan(textABC, num42)
        XCTAssertGreaterThan(textDEF, num42)
        XCTAssertGreaterThan(textABC, num142)
        XCTAssertGreaterThan(textDEF, num142)
    }
}
