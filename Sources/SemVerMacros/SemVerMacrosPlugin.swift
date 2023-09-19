import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct SemVerMacrosPlugin: CompilerPlugin {
    let providingMacros: Array<any Macro.Type> = [
        VersionMacro.self,
    ]
}
