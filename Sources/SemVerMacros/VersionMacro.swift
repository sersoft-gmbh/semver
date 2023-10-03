@_exported import SemVer

/// Parses a string to a ``Version`` at compile time.
@freestanding(expression)
public macro version(_ string: StaticString) -> Version = #externalMacro(module: "SemVerMacrosPlugin", type: "VersionMacro")

