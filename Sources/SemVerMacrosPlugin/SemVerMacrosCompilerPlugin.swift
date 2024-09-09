#if canImport(SwiftCompilerPlugin)
#if swift(<6.0)
public import SwiftCompilerPlugin
public import SwiftSyntaxMacros
#else
import SwiftCompilerPlugin
import SwiftSyntaxMacros
#endif

@main
struct SemVerMacrosCompilerPlugin: CompilerPlugin {
    let providingMacros: Array<any Macro.Type> = [
        VersionMacro.self,
    ]
}
#endif
