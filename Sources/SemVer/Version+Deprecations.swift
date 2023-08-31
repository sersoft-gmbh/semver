extension Version {
    /// The prelease part of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    /// - SeeAlso: `CharacterSet.versionSuffixAllowed`
    @available(*, deprecated, message: "Use preReleaseIdentifiers")
    public var prerelease: String {
        get { _preReleaseString }
        set { preReleaseIdentifiers = Self._splitIdentifiers(newValue) }
    }

    /// Creates a new version with the given parts.
    ///
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - prerelease: The prelease part of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    ///   - metadata: The metadata of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    @available(*, deprecated, message: "Use init(major:minor:patch:preReleaseIdentifiers:metadata:)")
    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: String, metadata: Array<String> = .init()) {
        self.init(major: major, minor: minor, patch: patch,
                  preReleaseIdentifiers: Self._splitIdentifiers(prerelease),
                  metadata: metadata)
    }

    /// Creates a new version with the given parts.
    ///
    /// - Parameters:
    ///   - major: The major part of this version. Must be >= 0.
    ///   - minor: The minor part of this version. Must be >= 0.
    ///   - patch: The patch part of this version. Must be >= 0.
    ///   - prerelease: The prelease part of this version. Must only contain characters in `CharacterSet.versionSuffixAllowed`.
    ///   - metadata: The metadata of this version. Must only chontain caracters in `CharacterSet.versionSuffixAllowed`.
    @inlinable
    @available(*, deprecated, message: "Use init(major:minor:patch:preReleaseIdentifiers:metadata:)")
    public init(major: Int, minor: Int = 0, patch: Int = 0, prerelease: String, metadata: String...) {
        self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }
}
