import XCTest
@testable import SemVerMacros

final class SemVerMacrosPluginTests: XCTestCase {
    func testProvidedMacros() {
        let macros = SemVerMacrosPlugin().providingMacros
        XCTAssertTrue(macros.contains { $0 == VersionMacro.self })
    }
}
