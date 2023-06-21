extension Version {
    /// Describes a set options that define the formatting behavior.
    @frozen
    public struct FormattingOptions: OptionSet, Hashable, Sendable {
        public typealias RawValue = Int

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
    }
}

extension Version.FormattingOptions {
    /// Leave out patch part if it's zero.
    public static let dropPatchIfZero = Version.FormattingOptions(rawValue: 1 << 0)
    /// Leave out minor part if it's zero. Requires `dropPatchIfZero`.
    public static let dropMinorIfZero = Version.FormattingOptions(rawValue: 1 << 1)
    /// Include the prerelease part of the version.
    public static let includePrerelease = Version.FormattingOptions(rawValue: 1 << 2)
    /// Include the metadata part of the version.
    public static let includeMetadata = Version.FormattingOptions(rawValue: 1 << 3)

    /// Combination of `.includePrerelease` and `.includeMetadata`.
    @inlinable
    public static var fullVersion: Version.FormattingOptions { [.includePrerelease, .includeMetadata] }
    /// Combination of `.dropPatchIfZero` and `.dropMinorIfZero`.
    @inlinable
    public static var dropTrailingZeros: Version.FormattingOptions { [.dropMinorIfZero, .dropPatchIfZero] }
}
