import struct Foundation.CharacterSet

@frozen
package enum VersionParser: Sendable {
    package enum VersionPrereleaseIdentifier: Sendable, Hashable {
        case number(Int)
        case text(String)
    }

    package typealias VersionComponents = (
        major: Int, minor: Int, patch: Int,
        prerelease: Array<VersionPrereleaseIdentifier>,
        metadata: Array<String>
    )

    private static func _parsePrereleaseIdentifiers<S>(_ identifiers: some Sequence<S>) -> some Sequence<VersionPrereleaseIdentifier>
    where S: StringProtocol, S.SubSequence == Substring
    {
        assert(identifiers.allSatisfy(_isValidIdentifier))
        return identifiers.lazy.map { Int($0).map { .number($0) } ?? .text(String($0)) }
    }

    private static func _parsePrereleaseIdentifiers<S>(_ identifiers: S) -> Array<VersionPrereleaseIdentifier>
    where S: StringProtocol, S.SubSequence == Substring
    {
        Array(_parsePrereleaseIdentifiers(_splitIdentifiers(identifiers)))
    }

    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, macCatalyst 16, *)
    @usableFromInline
    internal static func _parseModern<S>(_ string: S) -> VersionComponents?
    where S: StringProtocol, S.SubSequence == Substring
    {
        assert(!string.isEmpty)
        let fullRegex = #/^(?'major'\d+)(?:\.(?'minor'\d+)(?:\.(?'patch'\d+))?)?(?'prelease'-(?:[0-9A-Za-z-]+\.?)*)?(?'build'\+(?:[0-9A-Za-z-]+(?:\.|$))*)?$/#
        guard let fullMatch = string.wholeMatch(of: fullRegex),
              fullMatch.output.prelease?.count != 1,
              fullMatch.output.build?.count != 1,
              fullMatch.output.prelease?.last != ".",
              fullMatch.output.build?.last != ".",
              let major = Int(fullMatch.output.major)
        else { return nil }
        let minor = fullMatch.output.minor.flatMap { Int($0) } ?? 0
        let patch = fullMatch.output.patch.flatMap { Int($0) } ?? 0
        let prerelease = (fullMatch.output.prelease?.dropFirst()).map(_parsePrereleaseIdentifiers) ?? .init()
        let metadata = (fullMatch.output.build?.dropFirst()).map(_splitIdentifiers) ?? .init()
        return (major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    @usableFromInline
    internal static func _parseLegacy<S>(_ string: S) -> VersionComponents?
    where S: StringProtocol, S.SubSequence == Substring
    {
        assert(!string.isEmpty)
        guard string.range(of: #"^(?:[0-9]+\.){0,2}[0-9]+(?:-(?:[0-9A-Za-z-]+\.?)*)?(?:\+(?:[0-9A-Za-z-]+(?:\.|$))*)?$"#,
                           options: .regularExpression) != nil
        else { return nil }

        // This should be fine after above's regular expression
        let idx = string.range(of: #"[0-9](\+|-)"#, options: .regularExpression)
            .map { string.index(before: $0.upperBound) } ?? string.endIndex
        var parts: Array<String> = string[..<idx].components(separatedBy: ".").reversed()
        guard (1...3).contains(parts.count),
              let major = parts.popLast().flatMap(Int.init)
        else { return nil }
        let minor = parts.popLast().flatMap(Int.init) ?? 0
        let patch = parts.popLast().flatMap(Int.init) ?? 0

        let prerelease: Array<VersionPrereleaseIdentifier>
        if let searchRange = string.range(of: #"(?:^|\.)[0-9]+-(?:[0-9A-Za-z-]+\.?)*(?:\+|$)"#, options: .regularExpression),
           case let substr = string[searchRange],
           let range = substr.range(of: #"[0-9]-(?:[0-9A-Za-z-]+\.?)+"#, options: .regularExpression) {
            let prereleaseString = substr[substr.index(range.lowerBound, offsetBy: 2)..<range.upperBound]
            guard prereleaseString.last != "." else { return nil }
            prerelease = _parsePrereleaseIdentifiers(prereleaseString)
        } else {
            prerelease = .init()
        }

        let metadata: Array<String>
        if let range = string.range(of: #"\+(?:[0-9A-Za-z-]+(?:\.|$))+$"#, options: .regularExpression) {
            let metadataString = string[string.index(after: range.lowerBound)..<range.upperBound]
            guard metadataString.last != "." else { return nil }
            metadata = _splitIdentifiers(metadataString)
        } else {
            metadata = .init()
        }

        return (major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    @inlinable
    package static func parseString<S>(_ string: S) -> VersionComponents?
    where S: StringProtocol, S.SubSequence == Substring
    {
        guard !string.isEmpty else { return nil }
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, macCatalyst 16, *) {
            return _parseModern(string)
        } else {
            return _parseLegacy(string)
        }
    }
}

@_spi(SemVerValidation)
extension VersionParser {
    private static var _identifierSeparator: Character { "." }

    // Dance necessary because CharacterSet doesn't conform to Sendable in scf...
#if !canImport(Darwin) && swift(>=5.10)
    package static nonisolated(unsafe) let versionSuffixAllowedCharacterSet: CharacterSet = {
        var validCharset = CharacterSet.alphanumerics
        validCharset.insert("-")
        return validCharset
    }()
#else
    package static let versionSuffixAllowedCharacterSet: CharacterSet = {
        var validCharset = CharacterSet.alphanumerics
        validCharset.insert("-")
        return validCharset
    }()
#endif

    @inlinable
    package static func _isValidIdentifier(_ identifier: some StringProtocol) -> Bool {
        !identifier.isEmpty && CharacterSet(charactersIn: String(identifier)).isSubset(of: versionSuffixAllowedCharacterSet)
    }

    package static func _joinIdentifiers(_ identifiers: some Sequence<String>) -> String {
        identifiers.joined(separator: String(_identifierSeparator))
    }

    package static func _splitIdentifiers<S>(_ identifier: S) -> Array<String>
    where S: StringProtocol, S.SubSequence == Substring
    {
        identifier.split(separator: _identifierSeparator).map(String.init)
    }
}
