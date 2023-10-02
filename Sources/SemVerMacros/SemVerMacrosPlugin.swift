#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SemVerMacrosPlugin: CompilerPlugin {
    let providingMacros: Array<any Macro.Type> = [
        VersionMacro.self,
    ]
}
#endif
