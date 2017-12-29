import struct Foundation.CharacterSet

public extension CharacterSet {
    public static let versionSuffixAllowed: CharacterSet = {
        var validCharset = alphanumerics
        validCharset.insert(charactersIn: "-")
        return validCharset
    }()
}

// See http://semver.org
public struct Version: Hashable, Comparable, LosslessStringConvertible {
    public var major: Int {
        willSet { assert(newValue >= 0) }
    }
    public var minor: Int {
        willSet { assert(newValue >= 0) }
    }
    public var patch: Int {
        willSet { assert(newValue >= 0) }
    }
    public var prerelease: String {
        willSet { assert(CharacterSet(charactersIn: newValue).isSubset(of: .versionSuffixAllowed)) }
    }
    public var metadata: [String] {
        willSet {
            assert(!newValue.contains { !CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) })
            assert(!newValue.contains { $0.isEmpty })
        }
    }

    public var hashValue: Int {
        return major.hashValue ^ minor.hashValue ^ patch.hashValue ^ prerelease.hashValue
    }

    public var description: String {
        return versionString()
    }

    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: String = "", metadata: [String] = []) {
        assert(major >= 0)
        assert(minor >= 0)
        assert(patch >= 0)
        assert(CharacterSet(charactersIn: prerelease).isSubset(of: .versionSuffixAllowed))
        assert(!metadata.contains { !CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) })
        assert(!metadata.contains { $0.isEmpty })

        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.metadata = metadata
    }

    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: String = "", metadata: String...) {
        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    public init?(_ description: String) {
        guard !description.isEmpty else { return nil }
        guard description.range(of: "^([0-9]+\\.){0,2}[0-9]+(-[0-9A-Za-z-]+)?(\\+([0-9A-Za-z-]+\\.?)*)?$", options: .regularExpression) != nil
            else { return nil }

        // This should be fine after above's regular expression
        let idx = description.range(of: "[0-9](\\+|-)", options: .regularExpression).map { description.index(before: $0.upperBound) } ?? description.endIndex
        var parts: Array<String> = description[..<idx].components(separatedBy: ".").reversed()
        guard (1...3).contains(parts.count),
            let major = parts.popLast().flatMap(Int.init)
            else { return nil }
        let minor = parts.popLast().flatMap(Int.init) ?? 0
        let patch = parts.popLast().flatMap(Int.init) ?? 0

        let prerelease: String
        if let searchRange = description.range(of: "(^|\\.)[0-9]+-[0-9A-Za-z-]+(\\+|$)", options: .regularExpression),
            case let substr = description[searchRange],
            let range = substr.range(of: "[0-9]-[0-9A-Za-z-]+", options: .regularExpression) {
            prerelease = String(substr[substr.index(range.lowerBound, offsetBy: 2)..<range.upperBound])
        } else {
            prerelease = ""
        }

        let metadata: [String]
        if let range = description.range(of: "\\+([0-9A-Za-z-]+\\.?)+$", options: .regularExpression) {
            let metadataString = description[description.index(after: range.lowerBound)..<range.upperBound]
            metadata = metadataString.components(separatedBy: ".")
        } else {
            metadata = []
        }

        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }

    public func versionString(formattedWith options: FormattingOptions = .fullVersion) -> String {
        var versionString = "\(major)"
        if !options.contains(.dropPatchIfZero) || patch != 0 {
            versionString += ".\(minor).\(patch)"
        } else if !options.contains(.dropMinorIfZero) || minor != 0 {
            versionString += ".\(minor)"
        }
        if options.contains(.includePrerelease) && !prerelease.isEmpty {
            versionString += "-\(prerelease)"
        }
        if options.contains(.includeMetadata) && !metadata.isEmpty {
            versionString += "+\(metadata.joined(separator: "."))"
        }
        return versionString
    }
}

// MARK: - Comparison
public extension Version {
    public static func ==(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.patch, lhs.prerelease)
                                    ==
               (rhs.major, rhs.minor, rhs.patch, rhs.prerelease)
    }

    public static func <(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.patch)
                                <
               (rhs.major, rhs.minor, rhs.patch)
                                || // A version with a prerelease has a lower precedence than the same without
               ((!lhs.prerelease.isEmpty && rhs.prerelease.isEmpty) || (lhs.prerelease < rhs.prerelease))
    }

    public static func >(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.patch)
                                >
               (rhs.major, rhs.minor, rhs.patch)
                                || // A version with a prerelease has a lower precedence than the same without
               ((lhs.prerelease.isEmpty && !rhs.prerelease.isEmpty) || (lhs.prerelease > rhs.prerelease))
    }
}

// MARK: - Formatting Options
public extension Version {
    public struct FormattingOptions: OptionSet {
        public typealias RawValue = Int

        public let rawValue: RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
    }
}

public extension Version.FormattingOptions {
    static let dropPatchIfZero: Version.FormattingOptions = .init(rawValue: 1 << 0)
    static let dropMinorIfZero: Version.FormattingOptions = .init(rawValue: 1 << 1)
    static let includePrerelease: Version.FormattingOptions = .init(rawValue: 1 << 2)
    static let includeMetadata: Version.FormattingOptions = .init(rawValue: 1 << 3)

    /// Combination of .includePrerelease and .includeMetadata
    public static let fullVersion: Version.FormattingOptions = [.includePrerelease, .includeMetadata]
    /// Combination of .dropPatchIfZero and .dropMinorIfZero
    public static let dropTrailingZeros: Version.FormattingOptions = [.dropMinorIfZero, .dropPatchIfZero]
}

// MARK: - Deprecations
public extension Version {
    @available(*, deprecated, message: "Use formatting options")
    public func versionString(includingPrerelease: Bool, includingMetadata: Bool) -> String {
        var options: FormattingOptions = []
        if includingPrerelease { options.insert(.includePrerelease) }
        if includingMetadata { options.insert(.includeMetadata) }
        return versionString(formattedWith: options)
    }

    @available(*, deprecated, message: "Use formatting options")
    public func versionString(includingPrerelease: Bool) -> String {
        return versionString(includingPrerelease: includingPrerelease, includingMetadata: true)
    }

    @available(*, deprecated, message: "Use formatting options")
    public func versionString(includingMetadata: Bool) -> String {
        return versionString(includingPrerelease: true, includingMetadata: includingMetadata)
    }
}
