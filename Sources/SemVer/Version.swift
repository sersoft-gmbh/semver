import struct Foundation.CharacterSet

extension CharacterSet {
    /// Contains the allowed characters for a Version suffix (Version.prelease and Version.metadata)
    /// Allowed are alphanumerics and hyphen.
    public static let versionSuffixAllowed: CharacterSet = {
        var validCharset = alphanumerics
        validCharset.insert("-")
        return validCharset
    }()
}

/// A Version struct that implements the rules of semantic versioning.
/// - SeeAlso: https://semver.org
public struct Version: Sendable, Hashable, Comparable, LosslessStringConvertible, CustomDebugStringConvertible {
    /// The major part of this version. Must be >= 0.
    public var major: Int {
        willSet { assert(newValue >= 0) }
    }
    /// The minor part of this version. Must be >= 0.
    public var minor: Int {
        willSet { assert(newValue >= 0) }
    }
    /// The patch part of this version. Must be >= 0.
    public var patch: Int {
        willSet { assert(newValue >= 0) }
    }
    /// The prelease identifiers of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    /// - SeeAlso: `CharacterSet.versionSuffixAllowed`
    public var preReleaseIdentifiers: Array<String> {
        willSet { assert(Self._areValidIdentifiers(newValue)) }
    }
    /// The metadata of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    /// - SeeAlso: `CharacterSet.versionSuffixAllowed`
    public var metadata: Array<String> {
        willSet { assert(Self._areValidIdentifiers(newValue)) }
    }

    @inlinable
    public var description: String { versionString() }

    public var debugDescription: String {
        "Version(major: \(major), minor: \(minor), patch: \(patch), prelease: \"\(_preReleaseString)\", metadata: \"\(_metadataString)\")"
    }

    /// Creates a new version with the given parts.
    ///
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - preReleaseIdentifiers: The prelease identifiers of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    ///   - metadata: The metadata of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    public init(major: Int, minor: Int = 0, patch: Int = 0,
                preReleaseIdentifiers: Array<String> = .init(),
                metadata: Array<String> = .init()) {
        assert(major >= 0)
        assert(minor >= 0)
        assert(patch >= 0)
        assert(Self._areValidIdentifiers(preReleaseIdentifiers))
        assert(Self._areValidIdentifiers(metadata))

        self.major = major
        self.minor = minor
        self.patch = patch
        self.preReleaseIdentifiers = preReleaseIdentifiers
        self.metadata = metadata
    }

    /// Creates a new version with the given parts.
    ///
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - preReleaseIdentifiers: The prelease identifiers of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    ///   - metadata: The metadata of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    @inlinable
    public init(major: Int, minor: Int = 0, patch: Int = 0, preReleaseIdentifiers: Array<String> = .init(), metadata: String...) {
        self.init(major: major, minor: minor, patch: patch, preReleaseIdentifiers: preReleaseIdentifiers, metadata: metadata)
    }

    /// Creates a new version with the given parts.
    ///
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - preReleaseIdentifiers: The prelease identifiers of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    ///   - metadata: The metadata of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    @inlinable
    public init(major: Int, minor: Int = 0, patch: Int = 0, preReleaseIdentifiers: String..., metadata: Array<String> = .init()) {
        self.init(major: major, minor: minor, patch: patch, preReleaseIdentifiers: preReleaseIdentifiers, metadata: metadata)
    }

    /// Creates a new version with the given parts.
    ///
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - preReleaseIdentifiers: The prelease identifiers of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    ///   - metadata: The metadata of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    @inlinable
    public init(major: Int, minor: Int = 0, patch: Int = 0, preReleaseIdentifiers: String..., metadata: String...) {
        self.init(major: major, minor: minor, patch: patch, preReleaseIdentifiers: preReleaseIdentifiers, metadata: metadata)
    }

#if swift(>=5.7)
    @available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
    private init?(_modern description: String) {
        assert(!description.isEmpty)
        let fullRegex = #/^(?'major'\d+)(?:\.(?'minor'\d+)(?:\.(?'patch'\d+))?)?(?'prelease'-(?:[0-9A-Za-z-]+\.?)*)?(?'build'\+(?:[0-9A-Za-z-]+(?:\.|$))*)?$/#
        guard let fullMatch = description.wholeMatch(of: fullRegex),
              fullMatch.output.prelease?.count != 1,
              fullMatch.output.build?.count != 1,
              fullMatch.output.prelease?.last != ".",
              fullMatch.output.build?.last != "."
        else { return nil }
        let major = Int(fullMatch.output.major)!
        let minor = fullMatch.output.minor.flatMap { Int($0) } ?? 0
        let patch = fullMatch.output.patch.flatMap { Int($0) } ?? 0
        let preReleaseIdentifiers = (fullMatch.output.prelease?.dropFirst()).map(Self._splitIdentifiers) ?? .init()
        let metadata = (fullMatch.output.build?.dropFirst()).map(Self._splitIdentifiers) ?? .init()
        self.init(major: major, minor: minor, patch: patch, preReleaseIdentifiers: preReleaseIdentifiers, metadata: metadata)
    }
#endif

    private init?(_legacy description: String) {
        assert(!description.isEmpty)
        guard description.range(of: #"^(?:[0-9]+\.){0,2}[0-9]+(?:-(?:[0-9A-Za-z-]+\.?)*)?(?:\+(?:[0-9A-Za-z-]+(?:\.|$))*)?$"#,
                                options: .regularExpression) != nil
        else { return nil }

        // This should be fine after above's regular expression
        let idx = description.range(of: #"[0-9](\+|-)"#, options: .regularExpression)
            .map { description.index(before: $0.upperBound) } ?? description.endIndex
        var parts: Array<String> = description[..<idx].components(separatedBy: ".").reversed()
        guard (1...3).contains(parts.count),
              let major = parts.popLast().flatMap(Int.init)
        else { return nil }
        let minor = parts.popLast().flatMap(Int.init) ?? 0
        let patch = parts.popLast().flatMap(Int.init) ?? 0

        let preReleaseIdentifiers: Array<String>
        if let searchRange = description.range(of: #"(?:^|\.)[0-9]+-(?:[0-9A-Za-z-]+\.?)*(?:\+|$)"#, options: .regularExpression),
           case let substr = description[searchRange],
           let range = substr.range(of: #"[0-9]-(?:[0-9A-Za-z-]+\.?)+"#, options: .regularExpression) {
            let preReleaseString = substr[substr.index(range.lowerBound, offsetBy: 2)..<range.upperBound]
            if preReleaseString.last == "." { return nil }
            preReleaseIdentifiers = preReleaseString.components(separatedBy: ".")
        } else {
            preReleaseIdentifiers = .init()
        }

        let metadata: Array<String>
        if let range = description.range(of: #"\+(?:[0-9A-Za-z-]+(?:\.|$))+$"#, options: .regularExpression) {
            let metadataString = description[description.index(after: range.lowerBound)..<range.upperBound]
            if metadataString.last == "." { return nil }
            metadata = Self._splitIdentifiers(metadataString)
        } else {
            metadata = .init()
        }

        self.init(major: major, minor: minor, patch: patch, preReleaseIdentifiers: preReleaseIdentifiers, metadata: metadata)
    }

    public init?(_ description: String) {
        guard !description.isEmpty else { return nil }
#if swift(>=5.7)
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            self.init(_modern: description)
        } else {
            self.init(_legacy: description)
        }
#else
        self.init(_legacy: description)
#endif
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(preReleaseIdentifiers)
        // metadata does not participate in hashing and equating
    }

    /// Creates a version string using the given options.
    ///
    /// - Parameter options: The options to use for creating the version string.
    /// - Returns: A string containing the version formatted with the given options.
    public func versionString(formattedWith options: FormattingOptions = .fullVersion) -> String {
        var versionString = String(major)
        if !options.contains(.dropPatchIfZero) || patch != 0 {
            versionString += ".\(minor).\(patch)"
        } else if !options.contains(.dropMinorIfZero) || minor != 0 {
            versionString += ".\(minor)"
        }
        if options.contains(.includePrerelease) && !preReleaseIdentifiers.isEmpty {
            versionString += "-\(_preReleaseString)"
        }
        if options.contains(.includeMetadata) && !metadata.isEmpty {
            versionString += "+\(_metadataString)"
        }
        return versionString
    }
}

/* This currently does not work, due to the compiler ignoring the `init(_ description:)` for `Version("blah")` now.
// MARK: - String Literal Conversion
/// - Note: This conformance will crash if the given String literal is not a valid version!
extension Version: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral value: StringLiteralType) {
        guard let version = Self.init(value) else {
            fatalError("'\(value)' is not a valid semantic version!")
        }
        self = version
    }
}
*/

// MARK: - Comparison
extension Version {
    /// Returns whether this version is identical to another version (on all properties, including  ``metadata``).
    /// - Parameters:
    ///   - other: The version to compare to.
    ///   - requireIdenticalMetadataOrdering: Whether the metadata of both versions need to have the same order to be considered identical.
    /// - Returns: Whether the receiver is identical to `other`.
    public func isIdentical(to other: Version, requireIdenticalMetadataOrdering: Bool = false) -> Bool {
        guard self == other else { return false }
        return requireIdenticalMetadataOrdering
        ? metadata == other.metadata
        : metadata.count == other.metadata.count && Set(metadata) == Set(other.metadata)
    }

    public static func ==(lhs: Version, rhs: Version) -> Bool {
        (lhs.major, lhs.minor, lhs.patch, lhs.preReleaseIdentifiers)
            ==
        (rhs.major, rhs.minor, rhs.patch, rhs.preReleaseIdentifiers)
    }

    public static func <(lhs: Version, rhs: Version) -> Bool {
        if (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch) {
            return true
        }
        if (lhs.major, lhs.minor, lhs.patch) > (rhs.major, rhs.minor, rhs.patch) {
            return false
        }
        // A version with a pre-release has a lower precedence than the same version without pre-release.
        guard !lhs.preReleaseIdentifiers.isEmpty else { return false }
        guard !rhs.preReleaseIdentifiers.isEmpty else { return true }

        var (lhsPrereleaseIter, rhsPrereleaseIter) = (lhs.preReleaseIdentifiers.makeIterator(), rhs.preReleaseIdentifiers.makeIterator())
        while let lhsPrereleaseIdentifier = lhsPrereleaseIter.next(),
              let rhsPrereleaseIdentifier = rhsPrereleaseIter.next()
        {
            guard lhsPrereleaseIdentifier != rhsPrereleaseIdentifier else { continue }

            let lhsNumeric = Int(lhsPrereleaseIdentifier)
            let rhsNumeric = Int(rhsPrereleaseIdentifier)
            // Identifiers consisting of only digits are compared numerically.
            if let lhsNumeric = lhsNumeric, let rhsNumeric = rhsNumeric, lhsNumeric != rhsNumeric {
                return lhsNumeric < rhsNumeric
            }
            // Identifiers with letters or hyphens are compared lexically in ASCII sort order.
            if lhsNumeric == nil && rhsNumeric == nil {
                return lhsPrereleaseIdentifier < rhsPrereleaseIdentifier
            }
            // Numeric identifiers always have lower precedence than non-numeric identifiers.
            return lhsNumeric != nil && rhsNumeric == nil // The part after the `&&` is probably redundant here.
        }

        // A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.
        return lhs.preReleaseIdentifiers.count < rhs.preReleaseIdentifiers.count
    }
}

extension Version {
    static var _identifierSeparator: Character { "." }

    static func _areValidIdentifiers(_ identifiers: Array<String>) -> Bool {
        identifiers.allSatisfy { !$0.isEmpty && CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) }
    }

    @usableFromInline
    static func _joinIdentifiers(_ identifiers: Array<String>) -> String {
        identifiers.joined(separator: String(_identifierSeparator))
    }

    @usableFromInline
    static func _splitIdentifiers<S: StringProtocol>(_ identifier: S) -> Array<String>
    where S.SubSequence == String.SubSequence
    {
        identifier.split(separator: _identifierSeparator).map(String.init)
    }

    @inlinable
    var _preReleaseString: String { Self._joinIdentifiers(preReleaseIdentifiers) }
    @inlinable
    var _metadataString: String { Self._joinIdentifiers(metadata) }
}
