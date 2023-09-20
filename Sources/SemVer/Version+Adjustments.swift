extension Version {
    /// Lists all the numeric parts of a version (major, minor and patch).
    public enum NumericPart: Sendable, Hashable, CustomStringConvertible {
        /// The major version part.
        case major
        /// The minor version part.
        case minor
        /// The patch version part.
        case patch

        public var description: String {
            switch self {
            case .major: "major"
            case .minor: "minor"
            case .patch: "patch"
            }
        }
    }

    /// Returns the next version, increasing the given numeric part, respecting any associated rules:
    /// - If the major version is increased, minor and patch are set to 0.
    /// - If the minor version is increased, patch is set to 0
    /// - If the patch version is increased, no other changes are made.
    ///
    /// - Parameters:
    ///   - part: The numeric part to increase.
    ///   - keepingPrerelease: Whether or not the ``Version/prerelease`` should be kept. Defaults to `false`.
    ///   - keepingMetadata: Whether or not the ``Version/metadata`` should be kept. Defaults to `false`.
    /// - Returns: A new version that has the specified `part` increased, along with the necessary other changes.
    public func next(_ part: NumericPart, 
                     keepingPrerelease: Bool = false,
                     keepingMetadata: Bool = false) -> Self {
        let newPrerelease = keepingPrerelease ? prerelease : .init()
        let newMetadata = keepingMetadata ? metadata : .init()
        switch part {
        case .major: return Version(major: major + 1, minor: 0, patch: 0, prerelease: newPrerelease, metadata: newMetadata)
        case .minor: return Version(major: major, minor: minor + 1, patch: 0, prerelease: newPrerelease, metadata: newMetadata)
        case .patch: return Version(major: major, minor: minor, patch: patch + 1, prerelease: newPrerelease, metadata: newMetadata)
        }
    }

    /// Increases the given numeric part of the version, respecting any associated rules:
    /// - If the major version is increased, minor and patch are set to 0.
    /// - If the minor version is increased, patch is set to 0
    /// - If the patch version is increased, no other changes are made.
    ///
    /// - Parameters:
    ///   - part: The numeric part to increase.
    ///   - keepingPrerelease: Whether or not the ``Version/prerelease`` should be kept. Defaults to `false`.
    ///   - keepingMetadata: Whether or not the ``Version/metadata`` should be kept. Defaults to `false`.
    public mutating func increase(
        _ part: NumericPart,
        keepingPrerelease: Bool = false,
        keepingMetadata: Bool = false
    ) {
        switch part {
        case .major:
            major += 1
            (minor, patch) = (0, 0)
        case .minor:
            minor += 1
            patch = 0
        case .patch:
            patch += 1
        }
        if !keepingPrerelease {
            prerelease.removeAll()
        }
        if !keepingMetadata {
            metadata.removeAll()
        }
    }
}
