#if canImport(SemVerMacrosPlugin)
import Testing
@testable import SemVerMacrosPlugin

@Suite
struct SemVerMacrosCompilerPluginTests {
    @Test
    func providedMacros() {
        let macros = SemVerMacrosCompilerPlugin().providingMacros
        #expect(macros.count == 1)
        #expect(macros.contains { $0 == VersionMacro.self })
    }
}
#endif
