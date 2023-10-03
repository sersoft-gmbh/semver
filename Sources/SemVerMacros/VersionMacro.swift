import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
package import SemVerParsing

fileprivate extension DiagnosticMessage where Self == VersionMacro.DiagnosticMessage {
    static var notAStringLiteral: Self {
        .init(severity: .error, message: "#\(VersionMacro.name) requires a literal string (without any interpolations)!")
    }

    static func notAValidVersion(_ string: String) -> Self {
        .init(severity: .error, message: "Invalid version string: '\(string)'")
    }
}

public enum VersionMacro: ExpressionMacro {
    struct DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
        let diagnosticID: MessageID
        let severity: DiagnosticSeverity
        let message: String

        fileprivate init(id: String = #file, severity: DiagnosticSeverity, message: String) {
            self.diagnosticID = .init(domain: "de.sersoft.semver.version-macro", id: id)
            self.severity = severity
            self.message = message
        }
    }

    static let name = "version"

    public static func expansion(of node: some FreestandingMacroExpansionSyntax,
                                 in context: some MacroExpansionContext) throws -> ExprSyntax {
        assert(node.macro.text == name)
        guard let arg = node.argumentList.first else { fatalError("Missing argument!") }
        guard let stringLiteralExpr = arg.expression.as(StringLiteralExprSyntax.self),
              let string = stringLiteralExpr.representedLiteralValue
        else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: arg.expression, message: .notAStringLiteral),
            ])
        }
        guard let components = VersionParser.parseString(string) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: arg.expression, message: .notAValidVersion(string)),
            ])
        }
        return """
        SemVer.Version(
            major: \(literal: components.major),
            minor: \(literal: components.minor),
            patch: \(literal: components.patch),
            prerelease: \(ArrayExprSyntax(expressions: components.prerelease.map {
                switch $0 {
                case .number(let number): return "SemVer.Version.PrereleaseIdentifier(\(literal: number))"
                case .text(let text): return "SemVer.Version.PrereleaseIdentifier(unchecked: \(literal: text))"
                }
            })),
            metadata: \(literal: components.metadata)
        )
        """
    }
}
