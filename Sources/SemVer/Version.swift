import struct Foundation.CharacterSet

public extension CharacterSet {
   /// Contains the allowed characters for a Version suffix (Version.prelease and Version.metadata)
   /// Allowed are alphanumerics and hyphen.
   public static let versionSuffixAllowed: CharacterSet = {
      var validCharset = alphanumerics
      validCharset.insert(charactersIn: "-")
      return validCharset
   }()
}

/// A Version struct that implements the rules of semantic versioning.
/// - SeeAlso: http://semver.org
public struct Version: Hashable, Comparable, LosslessStringConvertible {
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
   /// The prelease part of this version. Must only contain caracters in `CharacterSet.versionSuffixAllowed`.
   /// - SeeAlso: `CharacterSet.versionSuffixAllowed`
   public var prerelease: String {
      willSet { assert(CharacterSet(charactersIn: newValue).isSubset(of: .versionSuffixAllowed)) }
   }
   /// The metadata of this version. Must only contain caracters in `CharacterSet.versionSuffixAllowed`.
   /// - SeeAlso: `CharacterSet.versionSuffixAllowed`
   public var metadata: [String] {
      willSet {
         assert(newValue.allSatisfy { !$0.isEmpty && CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) })
      }
   }

   public var description: String {
      return versionString()
   }

   /// Creates a new version with the given parts.
   ///
   /// - Parameters:
   ///   - major: The major part of this version. Must be >= 0.
   ///   - minor: The minor part of this version. Must be >= 0.
   ///   - patch: The patch part of this version. Must be >= 0.
   ///   - prerelease: The prelease part of this version. Must only contain caracters in `CharacterSet.versionSuffixAllowed`.
   ///   - metadata: The metadata of this version. Must only contain caracters in `CharacterSet.versionSuffixAllowed`.
   public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: String = "", metadata: [String] = []) {
      assert(major >= 0)
      assert(minor >= 0)
      assert(patch >= 0)
      assert(CharacterSet(charactersIn: prerelease).isSubset(of: .versionSuffixAllowed))
      assert(metadata.allSatisfy { !$0.isEmpty && CharacterSet(charactersIn: $0).isSubset(of: .versionSuffixAllowed) })

      self.major = major
      self.minor = minor
      self.patch = patch
      self.prerelease = prerelease
      self.metadata = metadata
   }

   /// Creates a new version with the given parts.
   ///
   /// - Parameters:
   ///   - major: The major part of this version. Must be >= 0.
   ///   - minor: The minor part of this version. Must be >= 0.
   ///   - patch: The patch part of this version. Must be >= 0.
   ///   - prerelease: The prelease part of this version. Must only contain caracters in `CharacterSet.versionSuffixAllowed`.
   ///   - metadata: The metadata of this version. Must only contain caracters in `CharacterSet.versionSuffixAllowed`.
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

   public func hash(into hasher: inout Hasher) {
      hasher.combine(major)
      hasher.combine(minor)
      hasher.combine(patch)
      hasher.combine(prerelease)
   }

   /// Creates a version string using the given options.
   ///
   /// - Parameter options: The options to use for creating the version string.
   /// - Returns: A string containing the version formatted with the given options.
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
   /// Leave out patch part if it's zero.
   static let dropPatchIfZero: Version.FormattingOptions = .init(rawValue: 1 << 0)
   /// Leave out minor part if it's zero. Requires `dropPatchIfZero`.
   static let dropMinorIfZero: Version.FormattingOptions = .init(rawValue: 1 << 1)
   /// Include the prerelease part of the version.
   static let includePrerelease: Version.FormattingOptions = .init(rawValue: 1 << 2)
   /// Include the metadata part of the version.
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
