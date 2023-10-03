import XCTest
@testable import SemVerMacrosPlugin

final class SemVerMacrosPluginTests: XCTestCase {
    func testProvidedMacros() {
        let macros = SemVerMacrosPlugin().providingMacros
        XCTAssertEqual(macros.count, 1)
        XCTAssertTrue(macros.contains { $0 == VersionMacro.self })
    }
}
