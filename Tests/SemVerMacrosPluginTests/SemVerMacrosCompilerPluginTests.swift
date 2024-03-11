#if canImport(SemVerMacrosPlugin)
import XCTest
@testable import SemVerMacrosPlugin

final class SemVerMacrosCompilerPluginTests: XCTestCase {
    func testProvidedMacros() {
        let macros = SemVerMacrosCompilerPlugin().providingMacros
        XCTAssertEqual(macros.count, 1)
        XCTAssertTrue(macros.contains { $0 == VersionMacro.self })
    }
}
#endif
