@_spi(SemVerValidation)
internal import SemVerParsing

extension Version {
    /// Represents a prerelease identifier of a version.
    public struct PrereleaseIdentifier: Sendable, Hashable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
        internal typealias _Storage = VersionParser.VersionPrereleaseIdentifier

        internal var _storage: _Storage

        @inlinable
        public var description: String { string }

        public var debugDescription: String {
            switch _storage {
            case .number(let number): "number(\(number))"
            case .text(let text): "text(\(text))"
            }
        }

        /// The string representation of this identifier.
        /// Numbers will be converted to strings.
        public var string: String {
            switch _storage {
            case .number(let number): String(number)
            case .text(let text): text
            }
        }

        /// The number representation of this identifier.
        /// Returns `nil` if the receiver represents a text identifier.
        public var number: Int? {
            switch _storage {
            case .number(let number): number
            case .text(_): nil
            }
        }

        internal init(_storage: _Storage) {
            assert({
                guard case .text(let text) = _storage
                else { return true }
                return Int(text) == nil
            }(), "Text storage is numeric!")
            self._storage = _storage
        }

        /// Creates a new identifier from a given number.
        /// - Parameter number: The number to store.
        public init(_ number: Int) {
            self.init(_storage: .number(number))
        }

        /// Creates a new identifier from a given string.
        /// This will also attempt to parse numbers (e.g. `"1"` will behave like `1`).
        /// - Parameter string: The string to parse. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``
        /// - SeeAlso: ``Foundation/CharacterSet/versionSuffixAllowed``
        public init(_ string: String) {
            assert(Version._isValidIdentifier(string))
            self.init(_storage: Int(string).map { .number($0) } ?? .text(string))
        }

        /// Creates a new identifier from a given string.
        /// This will **not** attempt to parse numbers!
        /// - Parameter string: The string to parse. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``
        /// - Precondition: The `string` cannot be represented as a number (`Int(string) == nil`)!
        public init(unchecked string: some StringProtocol) {
            assert(Version._isValidIdentifier(string))
            let _string = String(string)
            precondition(Int(_string) == nil)
            self.init(_storage: .text(_string))
        }

        /// Creates a new identifier from a given number.
        /// - Parameter number: The number to store.
        @inlinable
        public static func number(_ number: Int) -> Self {
            .init(number)
        }

        /// Creates a new identifier from a given string.
        /// This will also attempt to parse numbers (e.g. `"1"` will behave like `1`).
        /// - Parameter string: The string to parse. Must only contain characters in ``Foundation/CharacterSet/versionSuffixAllowed``
        /// - Returns: A new prerelease identifier.
        @inlinable
        public static func string(_ string: some StringProtocol) -> Self {
            .init(String(string))
        }

        public static func <(lhs: Self, rhs: Self) -> Bool {
            switch (lhs._storage, rhs._storage) {
                // Identifiers consisting of only digits are compared numerically.
            case (.number(let lhsNumber), .number(let rhsNumber)): lhsNumber < rhsNumber
                // Identifiers with letters or hyphens are compared lexically in ASCII sort order.
            case (.text(let lhsText), .text(let rhsText)): lhsText < rhsText
                // Numeric identifiers always have lower precedence than non-numeric identifiers.
            case (.number(_), .text(_)): true
            case (.text(_), .number(_)): false
            }
        }
    }
}

extension Version.PrereleaseIdentifier: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension Version.PrereleaseIdentifier: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension Version.PrereleaseIdentifier: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard Version._isValidIdentifier(string)
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: #"Invalid prerelease identifier: "\#(string)""#) }
        self.init(string)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}
