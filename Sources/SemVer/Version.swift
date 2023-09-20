import struct Foundation.CharacterSet
@_spi(SemVerValidation)
package import SemVerParsing

extension CharacterSet {
    /// Contains the allowed characters for a ``Version`` suffix (``Version/prerelease`` and ``Version/metadata``)
    /// Allowed are alphanumerics and hyphen.
    public static let versionSuffixAllowed: CharacterSet = VersionParser.versionSuffixAllowedCharacterSet
}

/// Parses a string to a ``Version`` at compile time.
@freestanding(expression)
public macro version(_ string: StaticString) -> Version = #externalMacro(module: "SemVerMacros", type: "VersionMacro")

/// A Version struct that implements the rules of semantic versioning.
/// - SeeAlso: [SemVer Specification](https://semver.org)
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
    /// The prelease identifiers of this version.
    public var prerelease: Array<PrereleaseIdentifier>
    /// The metadata of this version. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``.
    /// - SeeAlso: ``Foundation/CharacterSet/versionSuffixAllowed``
    public var metadata: Array<String> {
        willSet { assert(Self._areValidIdentifiers(newValue)) }
    }

    @inlinable
    public var description: String { versionString() }

    public var debugDescription: String {
        "Version(major: \(major), minor: \(minor), patch: \(patch), prelease: \"\(_prereleaseString)\", metadata: \"\(_metadataString)\")"
    }

    /// Creates a new version with the given parts.
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - prerelease: The prelease identifiers of this version.
    ///   - metadata: The metadata of this version. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``.
    public init(major: Int, minor: Int = 0, patch: Int = 0,
                prerelease: Array<PrereleaseIdentifier> = .init(),
                metadata: Array<String> = .init()) {
        assert(major >= 0)
        assert(minor >= 0)
        assert(patch >= 0)
        assert(Self._areValidIdentifiers(metadata))

        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.metadata = metadata
    }

    /// Creates a new version with the given parts.
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - prerelease: The prelease identifiers of this version.
    ///   - metadata: The metadata of this version. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``.
    @inlinable
    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: Array<PrereleaseIdentifier> = .init(), metadata: String...) {
        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    /// Creates a new version with the given parts.
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - prerelease: The prelease identifiers of this version.
    ///   - metadata: The metadata of this version. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``.
    @inlinable
    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: PrereleaseIdentifier..., metadata: Array<String> = .init()) {
        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    /// Creates a new version with the given parts.
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - prerelease: The prelease identifiers of this version.
    ///   - metadata: The metadata of this version. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``.
    @inlinable
    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: PrereleaseIdentifier..., metadata: String...) {
        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    public init?(_ description: String) {
        guard let components = VersionParser.parseString(description) else { return nil }
        self.init(major: components.major, 
                  minor: components.minor,
                  patch: components.patch,
                  prerelease: components.prerelease.map(PrereleaseIdentifier.init(_storage:)),
                  metadata: components.metadata)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(prerelease)
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
        if options.contains(.includePrerelease) && !prerelease.isEmpty {
            versionString += "-\(_prereleaseString)"
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
    /// Returns whether this version is identical to another version (on all properties, including  ``Version/metadata``).
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

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        (lhs.major, lhs.minor, lhs.patch, lhs.prerelease)
            ==
        (rhs.major, rhs.minor, rhs.patch, rhs.prerelease)
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        if (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch) {
            return true
        }
        if (lhs.major, lhs.minor, lhs.patch) > (rhs.major, rhs.minor, rhs.patch) {
            return false
        }
        // A version with a pre-release has a lower precedence than the same version without pre-release.
        guard !lhs.prerelease.isEmpty else { return false }
        guard !rhs.prerelease.isEmpty else { return true }

        // Skip all identifiers that are equal, then compare the first non-equal (if any).
        if let (lhsIdent, rhsIdent) = zip(lhs.prerelease, rhs.prerelease).drop(while: { $0 == $1 }).first(where: { _ in true }) {
            return lhsIdent < rhsIdent
        }

        // A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.
        return lhs.prerelease.count < rhs.prerelease.count
    }
}

extension Version {
    @usableFromInline
    static func _isValidIdentifier(_ identifiers: some StringProtocol) -> Bool {
        VersionParser._isValidIdentifier(identifiers)
    }

    @inlinable
    static func _areValidIdentifiers(_ identifiers: some Sequence<some StringProtocol>) -> Bool {
        identifiers.allSatisfy(_isValidIdentifier)
    }

    static func _splitIdentifiers<S>(_ identifier: S) -> Array<String>
    where S: StringProtocol, S.SubSequence == Substring
    {
        VersionParser._splitIdentifiers(identifier)
    }

    @usableFromInline
    var _prereleaseString: String { VersionParser._joinIdentifiers(prerelease.lazy.map(\.string)) }
    @usableFromInline
    var _metadataString: String { VersionParser._joinIdentifiers(metadata) }
}
