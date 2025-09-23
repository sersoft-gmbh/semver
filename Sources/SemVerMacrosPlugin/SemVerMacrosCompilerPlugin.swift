#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SemVerMacrosCompilerPlugin: CompilerPlugin {
    let providingMacros: Array<any Macro.Type> = [
        VersionMacro.self,
    ]
}
#endif
