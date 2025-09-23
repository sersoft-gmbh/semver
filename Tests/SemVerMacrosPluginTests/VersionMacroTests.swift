#if canImport(SemVerMacrosPlugin)
import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import SemVerMacrosPlugin

@Suite
struct VersionMacroTests {
    private let testMacros: Dictionary<String, MacroSpec> = [
        "version": .init(type: VersionMacro.self),
    ]

    private static func handleFailure(_ failure: TestFailureSpec) {
        Issue.record("\(failure.message)",
                     sourceLocation: .init(
                        fileID: failure.location.fileID,
                        filePath: failure.location.filePath,
                        line: failure.location.line,
                        column: failure.location.column))
    }

    @Test
    func validApplications() {
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
                             macroSpecs: testMacros,
                             failureHandler: Self.handleFailure)
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
                             macroSpecs: testMacros,
                             failureHandler: Self.handleFailure)
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
                             macroSpecs: testMacros,
                             failureHandler: Self.handleFailure)
    }

    @Test
    func invalidApplications() {
        assertMacroExpansion(#"#version("1.\(myMinorComponent).3")"#,
                             expandedSource: #"#version("1.\(myMinorComponent).3")"#,
                             diagnostics: [
                                .init(message: "#version requires a literal string (without any interpolations)!", line: 1, column: 10)
                             ],
                             macroSpecs: testMacros,
                             failureHandler: Self.handleFailure)
        assertMacroExpansion(#"#version("a.b.c")"#,
                             expandedSource: #"#version("a.b.c")"#,
                             diagnostics: [
                                .init(message: "Invalid version string: 'a.b.c'", line: 1, column: 10)
                             ],
                             macroSpecs: testMacros,
                             failureHandler: Self.handleFailure)
    }
}
#endif
