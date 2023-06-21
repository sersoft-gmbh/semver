import Foundation

extension CodingUserInfoKey {
    /// The key used to configure an `Encoder` with the strategy that should be used for encoding a ``Version``.
    public static let versionEncodingStrategy = CodingUserInfoKey(rawValue: "de.sersoft.semver.version.encoding-strategy")!
    /// The key used to configure an `Decoder` with the strategy that should be used for decoding a ``Version``.
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
        /// Encodes the version's components as separete keys.
        case components
        /// Encodes a version string using the given format.
        case string(Version.FormattingOptions)
#if swift(>=5.7)
        /// Uses the given closure for encoding a version.
        @preconcurrency
        case custom(@Sendable (Version, any Encoder) throws -> ())
#else
        /// Uses the given closure for encoding a version.
        @preconcurrency
        case custom(@Sendable (Version, Encoder) throws -> ())
#endif

        /// Convenience accessor representing `.string(.fullVersion)`.
        public static var string: Self { .string(.fullVersion) }

        @usableFromInline
        static var _default: Self { .components }
    }

    /// The strategy for decoding a ``Version``.
    public enum DecodingStrategy: Sendable {
        /// Decodes the version's components as separete keys.
        case components
        /// Decodes a version from a string.
        case string
#if swift(>=5.7)
        /// Uses the given closure for decoding a version.
        @preconcurrency
        case custom(@Sendable (any Decoder) throws -> Version)
#else
        /// Uses the given closure for decoding a version.
        @preconcurrency
        case custom(@Sendable (Decoder) throws -> Version)
#endif

        @usableFromInline
        static var _default: Self { .components }
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
        case .components:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(major, forKey: .major)
            try container.encode(minor, forKey: .minor)
            try container.encode(patch, forKey: .patch)
            try container.encode(prerelease, forKey: .prerelease)
            try container.encode(metadata, forKey: .metadata)
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
        case .components:
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                major: container.decode(Int.self, forKey: .major),
                minor: container.decodeIfPresent(Int.self, forKey: .minor) ?? 0,
                patch: container.decodeIfPresent(Int.self, forKey: .patch) ?? 0,
                prerelease: container.decodeIfPresent(String.self, forKey: .prerelease) ?? "",
                metadata: container.decodeIfPresent(Array<String>.self, forKey: .metadata) ?? .init()
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
