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
            assert(newValue.first { !CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) } == nil)
            assert(newValue.first { $0.isEmpty } == nil)
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
        assert(metadata.first { !CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) } == nil)
        assert(metadata.first { $0.isEmpty } == nil)
        
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
        guard description.range(of: "^([0-9]+\\.){2}[0-9]+(-[0-9A-Za-z-]+)?(\\+[0-9A-Za-z-]+\\.?)*$", options: [.regularExpression]) != nil
            else { return nil }
        
        // This should be fine after above's regular expression
        let idx = description.range(of: "[0-9](+|\\-)", options: [.regularExpression])?.upperBound ?? description.endIndex
        let parts = description.substring(to: idx).components(separatedBy: ".")
        guard parts.count == 3, // TODO: Should we support versions like "1.0"?
            let major = Int(parts[0]),
            let minor = Int(parts[1]),
            let patch = Int(parts[2])
            else { return nil }
        
        let prerelease: String
        if let range = description.range(of: "-[0-9A-Za-z-]+", options: [.regularExpression]) {
            prerelease = description.substring(with: description.index(after: range.lowerBound)..<range.upperBound)
        } else {
            prerelease = ""
        }

        let metadata: [String]
        if let range = description.range(of: "(\\+[0-9A-Za-z-]+\\.?)+$", options: [.regularExpression]) {
            let metadataString = description.substring(with: description.index(after: range.lowerBound)..<range.upperBound)
            metadata = metadataString.components(separatedBy: ".")
        } else {
            metadata = []
        }
        
        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }
    
    public func versionString(includingPrerelease: Bool = true, includingMetadata: Bool = true) -> String {
        var versionString = "\(major).\(minor).\(patch)"
        if includingPrerelease, !prerelease.isEmpty {
            versionString += "-\(prerelease)"
        }
        if includingMetadata, !metadata.isEmpty {
            versionString += "+\(metadata.joined(separator: "."))"
        }
        return versionString
    }
    
    public static func ==(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.patch, lhs.prerelease)
                                    ==
               (rhs.major, rhs.minor, rhs.patch, rhs.prerelease)
    }
    
    public static func <(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.patch, lhs.prerelease)
                                    <
               (rhs.major, rhs.minor, rhs.patch, rhs.prerelease)
    }
    
    public static func >(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.patch, lhs.prerelease)
                                    >
               (rhs.major, rhs.minor, rhs.patch, rhs.prerelease)
    }
}
