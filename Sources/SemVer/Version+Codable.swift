public import Foundation

extension CodingUserInfoKey {
    /// The key used to configure an ``Swift/Encoder`` with the strategy that should be used for encoding a ``Version``.
    public static let versionEncodingStrategy = CodingUserInfoKey(rawValue: "de.sersoft.semver.version.encoding-strategy")!
    /// The key used to configure an ``Swift/Decoder`` with the strategy that should be used for decoding a ``Version``.
    public static let versionDecodingStrategy = CodingUserInfoKey(rawValue: "de.sersoft.semver.version.decoding-strategy")!
}

extension Dictionary where Key == CodingUserInfoKey, Value == Any {
    @inlinable
    subscript<V>(_ key: Key) -> V? {
        get { self[key] as? V }
        set { self[key] = newValue }
    }
}

extension Version {
    fileprivate enum CodingKeys: String, CodingKey {
        case major, minor, patch, prerelease, metadata
    }
    
    /// The strategy for encoding a ``Version``.
    public enum EncodingStrategy: Sendable {
        /// Encodes the version's components as separate keys.
        /// - `prereleaseAsString` controls whether the ``Version/prerelease`` are encoded as list or string.
        /// - `metadataAsString` controls whether ``Version/metadata`` is encoded as list or string.
        case components(prereleaseAsString: Bool, metadataAsString: Bool)
        /// Encodes a version string using the given format.
        case string(Version.FormattingOptions)
        /// Uses the given closure for encoding a version.
        @preconcurrency
        case custom(@Sendable (Version, any Encoder) throws -> ())

        /// Convenience accessor representing `.components(prereleaseAsString: true, metadataAsString: false)`,
        /// which was the default of the non-parameterized `components`.
        public static var components: Self { .components(prereleaseAsString: true, metadataAsString: false) }

        /// Convenience accessor representing `.string(.fullVersion)`.
        public static var string: Self { .string(.fullVersion) }

        @usableFromInline
        internal static var _default: Self { .components }
    }

    /// The strategy for decoding a ``Version``.
    public enum DecodingStrategy: Sendable {
        /// Decodes the version's components as separate keys.
        /// - `prereleaseAsString` controls whether the ``Version/prerelease`` are decoded as list or string.
        /// - `metadataAsString` controls whether ``Version/metadata`` is decode as list or string.
        case components(prereleaseAsString: Bool, metadataAsString: Bool)
        /// Decodes a version from a string.
        case string
        /// Uses the given closure for decoding a version.
        @preconcurrency
        case custom(@Sendable (any Decoder) throws -> Version)

        /// Convenience accessor representing `.components(prereleaseAsString: true, metadataAsString: false)`,
        /// which was the default of the non-parameterized `components`.
        public static var components: Self { .components(prereleaseAsString: true, metadataAsString: false) }

        @usableFromInline
        internal static var _default: Self { .components }
    }
}

extension Version: Encodable {
    /// Encodes the version to the given encoder using the given strategy.
    /// - Parameters:
    ///   - encoder: The encoder to encode to.
    ///   - strategy: The strategy to use for encoding.
    @usableFromInline
    internal func encode(to encoder: any Encoder, using strategy: EncodingStrategy) throws {
        switch strategy {
        case .components(let prereleaseAsString, let metadataAsString):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(major, forKey: .major)
            try container.encode(minor, forKey: .minor)
            try container.encode(patch, forKey: .patch)
            if prereleaseAsString {
                try container.encode(_prereleaseString, forKey: .prerelease)
            } else {
                try container.encode(prerelease, forKey: .prerelease)
            }
            if metadataAsString {
                try container.encode(_metadataString, forKey: .metadata)
            } else {
                try container.encode(metadata, forKey: .metadata)
            }
        case .string(let options):
            var container = encoder.singleValueContainer()
            try container.encode(versionString(formattedWith: options))
        case .custom(let closure):
            try closure(self, encoder)
        }
    }

    @inlinable
    public func encode(to encoder: any Encoder) throws {
        try encode(to: encoder, using: encoder.userInfo[.versionEncodingStrategy] ?? ._default)
    }
}

extension Version: Decodable {
    /// Decodes a version from the given decoder using the given strategy.
    /// - Parameters:
    ///   - decoder: The decoder to decode from.
    ///   - strategy: The strategy to use for decoding.
    @usableFromInline
    internal init(from decoder: any Decoder, using strategy: DecodingStrategy) throws {
        switch strategy {
        case .components(let prereleaseAsString, let metadataAsString):
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let major = try container.decode(Int.self, forKey: .major)
            guard major >= 0
            else { throw DecodingError.dataCorruptedError(forKey: .major, in: container, debugDescription: "Invalid major version component: \(major)") }
            let minor = try container.decodeIfPresent(Int.self, forKey: .minor)
            guard minor.map({ $0 >= 0 }) != false
            else { throw DecodingError.dataCorruptedError(forKey: .minor, in: container, debugDescription: "Invalid minor version component: \(minor!)") }
            let patch = try container.decodeIfPresent(Int.self, forKey: .patch)
            guard patch.map({ $0 >= 0 }) != false
            else { throw DecodingError.dataCorruptedError(forKey: .patch, in: container, debugDescription: "Invalid patch version component: \(patch!)") }

            let prerelease: Array<PrereleaseIdentifier>?
            if prereleaseAsString {
                if let prereleaseIdentifiers = try container.decodeIfPresent(String.self, forKey: .prerelease).map(Self._splitIdentifiers) {
                    guard Self._areValidIdentifiers(prereleaseIdentifiers) 
                    else { throw DecodingError.dataCorruptedError(forKey: .prerelease, in: container, debugDescription: "Invalid prerelease: \(prereleaseIdentifiers)") }
                    prerelease = prereleaseIdentifiers.map(PrereleaseIdentifier.string)
                } else {
                    prerelease = nil
                }
            } else {
                prerelease = try container.decodeIfPresent(Array<PrereleaseIdentifier>.self, forKey: .prerelease)
            }

            let metadata: Array<String>?
            if metadataAsString {
                metadata = try container.decodeIfPresent(String.self, forKey: .metadata).map(Self._splitIdentifiers)
            } else {
                metadata = try container.decodeIfPresent(Array<String>.self, forKey: .metadata)
            }
            guard metadata.map(Self._areValidIdentifiers) != false
            else { throw DecodingError.dataCorruptedError(forKey: .patch, in: container, debugDescription: "Invalid metadata: \(metadata!)") }

            self.init(
                major: major,
                minor: minor ?? 0,
                patch: patch ?? 0,
                prerelease: prerelease ?? .init(),
                metadata: metadata ?? .init()
            )
        case .string:
            let string = try decoder.singleValueContainer().decode(String.self)
            guard let version = Version(string) else {
                throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath,
                                                        debugDescription: "Cannot convert \(string) to \(Version.self)!"))
            }
            self = version
        case .custom(let closure):
            self = try closure(decoder)
        }
    }

    @inlinable
    public init(from decoder: any Decoder) throws {
        try self.init(from: decoder, using: decoder.userInfo[.versionDecodingStrategy] ?? ._default)
    }
}

extension JSONEncoder {
    /// The strategy to use for encoding a ``Version``.
    public var semverVersionEncodingStrategy: Version.EncodingStrategy {
        get { userInfo[.versionEncodingStrategy] ?? ._default }
        set { userInfo[.versionEncodingStrategy] = newValue }
    }
}

extension PropertyListEncoder {
    /// The strategy to use for encoding a ``Version``.
    public var semverVersionEncodingStrategy: Version.EncodingStrategy {
        get { userInfo[.versionEncodingStrategy] ?? ._default }
        set { userInfo[.versionEncodingStrategy] = newValue }
    }
}

extension JSONDecoder {
    /// The strategy to use for decoding a ``Version``.
    public var semverVersionDecodingStrategy: Version.DecodingStrategy {
        get { userInfo[.versionDecodingStrategy] ?? ._default }
        set { userInfo[.versionDecodingStrategy] = newValue }
    }
}

extension PropertyListDecoder {
    /// The strategy to use for decoding a ``Version``.
    public var semverVersionDecodingStrategy: Version.DecodingStrategy {
        get { userInfo[.versionDecodingStrategy] ?? ._default }
        set { userInfo[.versionDecodingStrategy] = newValue }
    }
}
