#if canImport(SemVerMacrosPlugin)
import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SemVerMacrosPlugin

final class VersionMacroTests: XCTestCase {
    let testMacros: Dictionary<String, any Macro.Type> = [
        "version": VersionMacro.self,
    ]

    func testValidApplications() {
        assertMacroExpansion(#"#version("1.2.3")"#,
                             expandedSource: """
                             SemVer.Version(
                                 major: 1,
                                 minor: 2,
                                 patch: 3,
                                 prerelease: [],
                                 metadata: []
                             )
                             """,
                             macros: testMacros)
        assertMacroExpansion(#"#version("1.2.3-beta.1")"#,
                             expandedSource: """
                             SemVer.Version(
                                 major: 1,
                                 minor: 2,
                                 patch: 3,
                                 prerelease: [SemVer.Version.PrereleaseIdentifier(unchecked: "beta"), SemVer.Version.PrereleaseIdentifier(1)],
                                 metadata: []
                             )
                             """,
                             macros: testMacros)
        assertMacroExpansion(#"#version("1.2.3-beta.1+annotation.x")"#,
                             expandedSource: """
                             SemVer.Version(
                                 major: 1,
                                 minor: 2,
                                 patch: 3,
                                 prerelease: [SemVer.Version.PrereleaseIdentifier(unchecked: "beta"), SemVer.Version.PrereleaseIdentifier(1)],
                                 metadata: ["annotation", "x"]
                             )
                             """,
                             macros: testMacros)
    }

    func testInvalidApplications() {
        assertMacroExpansion(#"#version("1.\(myMinorComponent).3")"#,
                             expandedSource: #"#version("1.\(myMinorComponent).3")"#,
                             diagnostics: [
                                .init(message: "#version requires a literal string (without any interpolations)!", line: 1, column: 10)
                             ],
                             macros: testMacros)
        assertMacroExpansion(#"#version("a.b.c")"#,
                             expandedSource: #"#version("a.b.c")"#,
                             diagnostics: [
                                .init(message: "Invalid version string: 'a.b.c'", line: 1, column: 10)
                             ],
                             macros: testMacros)
    }
}
#endif
