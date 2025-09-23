import Testing
@testable import SemVer
import SemVerMacros

@Suite
struct VersionTests {
    @Test
    func fullVersionString() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        #expect(version.versionString() == "1.2.3-beta+exp.test")
    }

    @Test
    func fullVersionStringWithSuffixWithoutData() {
        let version = Version(major: 1, minor: 2, patch: 3)
        #expect(version.versionString() == "1.2.3")
    }

    @Test
    func fullVersionStringWithoutPrereleaseDataWithMetadataData() {
        let version = Version(major: 1, minor: 2, patch: 3, metadata: "exp-1", "test")
        #expect(version.versionString() == "1.2.3+exp-1.test")
    }

    @Test
    func fullVersionStringWithPrereleaseDataWithoutMetadataData() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta-1")
        #expect(version.versionString() == "1.2.3-beta-1")
    }

    @Test
    func versionStringExcludingPrerelease() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        #expect(version.versionString(formattedWith: .includeMetadata) == "1.2.3+exp.test")
    }

    @Test
    func versionStringExcludingMetadata() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        #expect(version.versionString(formattedWith: .includePrerelease) == "1.2.3-beta")
    }

    @Test
    func versionStringWhenDroppingZeros() {
        let version1 = Version(major: 1, minor: 0, patch: 0)
        let version2 = Version(major: 2, minor: 0, patch: 1)
        let version3 = Version(major: 3, minor: 1, patch: 0)

        #expect(version1.versionString(formattedWith: [.fullVersion, .dropTrailingZeros]) == "1")
        #expect(version1.versionString(formattedWith: [.fullVersion, .dropPatchIfZero]) == "1.0")
        #expect(version1.versionString(formattedWith: [.fullVersion, .dropMinorIfZero]) == "1.0.0")
        #expect(version2.versionString(formattedWith: [.fullVersion, .dropTrailingZeros]) == "2.0.1")
        #expect(version2.versionString(formattedWith: [.fullVersion, .dropPatchIfZero]) == "2.0.1")
        #expect(version2.versionString(formattedWith: [.fullVersion, .dropMinorIfZero]) == "2.0.1")
        #expect(version3.versionString(formattedWith: [.fullVersion, .dropTrailingZeros]) == "3.1")
        #expect(version3.versionString(formattedWith: [.fullVersion, .dropPatchIfZero]) == "3.1")
        #expect(version3.versionString(formattedWith: [.fullVersion, .dropMinorIfZero]) == "3.1.0")
    }

    @Test
    func descriptionIsEqualToFullVersionString() {
        let version = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        #expect(String(describing: version) == version.versionString())
    }

    @Test
    func versionEqualityWithBasicVersion() {
        let v1 = Version(major: 1, minor: 2, patch: 3)
        let v2 = Version(major: 1, minor: 2, patch: 3)
        let v3 = Version(major: 2, minor: 0, patch: 0)

        #expect(v1 == v2)
        #expect(v1 != v3)
        #expect(v2 != v3)
    }

    @Test
    func versionEqualityWithMetadataDifference() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
        let v3 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta2")

        #expect(v1 == v2)
        #expect(v1 != v3)
        #expect(v2 != v3)
    }

    @Test
    func versionIdenticalCheck() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
        let v3 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "test", "exp")
        let v4 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp2")
        let v5 = Version(major: 1, minor: 3)

        #expect(v1.isIdentical(to: v1))
        #expect(v1.isIdentical(to: v1, requireIdenticalMetadataOrdering: true))
        #expect(!v1.isIdentical(to: v2))
        #expect(v1.isIdentical(to: v3))
        #expect(!v1.isIdentical(to: v3, requireIdenticalMetadataOrdering: true))
        #expect(!v1.isIdentical(to: v4))
        #expect(!v1.isIdentical(to: v5))
        #expect(!v1.isIdentical(to: v5, requireIdenticalMetadataOrdering: true))
    }

    @Test
    func versionComparison() {
        let v0 = Version(major: 0, patch: 1)
        let v1 = Version(major: 1, minor: 2, patch: 3)
        let v2 = Version(major: 1, minor: 2, patch: 4)
        let v3 = Version(major: 2, minor: 0, patch: 0)
        let v3b = Version(major: 2, minor: 0, patch: 0, prerelease: "beta")
        let v3be = Version(major: 2, minor: 0, patch: 0, prerelease: "beta", metadata: "ext")
        let v4 = Version(major: 4)
        let v4b1 = Version(major: 4, prerelease: "beta1")
        let v4b2 = Version(major: 4, prerelease: "beta2")

        let v123 = Version(major: 1, minor: 2, patch: 3)
        let v124 = Version(major: 1, minor: 2, patch: 4)
        let v123Alpha = Version(major: 1, minor: 2, patch: 3, prerelease: "alpha")
        let v123Beta = Version(major: 1, minor: 2, patch: 3, prerelease: "beta")
        let v1AlphaBeta1 = Version(major: 1, prerelease: "alpha", "beta", 1)
        let v1Alpha1Beta = Version(major: 1, prerelease: "alpha", 1, "beta")

        #expect(v0 < v1)
        #expect(v1 < v2)
        #expect(v2 < v3)
        #expect(v3b < v3)
        #expect(v3be < v3)
        #expect(v4b1 < v4b2)
        #expect(v4b1 < v4)
        #expect(v4b2 < v4)

        #expect(v3 > v0)
        #expect(v3 > v1)
        #expect(v3 > v2)
        #expect(v3 > v3b)
        #expect(v3 > v3be)
        #expect(v4b2 > v4b1)
        #expect(v4 > v4b1)
        #expect(v4 > v4b2)

        #expect(!(v123 < v123))
        #expect(!(v123Alpha < v123Alpha))
        #expect(!(v123Beta < v123Beta))

        #expect(!(v123 > v123))
        #expect(!(v123Alpha > v123Alpha))
        #expect(!(v123Beta > v123Beta))

        #expect(v123Alpha < v123)
        #expect(v123Alpha < v123Beta)
        #expect(v123Alpha < v124)
        #expect(v123Beta < v123)
        #expect(v123Beta < v124)
        #expect(v123 < v124)

        #expect(!(v123 < v123Alpha))
        #expect(!(v123Beta < v123Alpha))
        #expect(!(v124 < v123Alpha))
        #expect(!(v123 < v123Beta))
        #expect(!(v124 < v123Beta))
        #expect(!(v124 < v123))

        #expect(!(v123Alpha > v123))
        #expect(!(v123Alpha > v123Beta))
        #expect(!(v123Alpha > v124))
        #expect(!(v123Beta > v123))
        #expect(!(v123Beta > v124))
        #expect(!(v123 > v124))

        #expect(v123 > v123Alpha)
        #expect(v123Beta > v123Alpha)
        #expect(v124 > v123Alpha)
        #expect(v123 > v123Beta)
        #expect(v124 > v123Beta)
        #expect(v124 > v123)

        #expect(!(v1Alpha1Beta > v1AlphaBeta1))
    }

    @Test
    func comparisonFromSpec() {
        // 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
        let v1 = Version(major: 1, prerelease: "alpha")
        let v2 = Version(major: 1, prerelease: "alpha", "1")
        let v3 = Version(major: 1, prerelease: "alpha", "beta")
        let v4 = Version(major: 1, prerelease: "beta")
        let v5 = Version(major: 1, prerelease: "beta", "2")
        let v6 = Version(major: 1, prerelease: "beta", "11")
        let v7 = Version(major: 1, prerelease: "rc", "1")
        let v8 = Version(major: 1)

        #expect(v1 < v2)
        #expect(v2 < v3)
        #expect(v3 < v4)
        #expect(v4 < v5)
        #expect(v5 < v6)
        #expect(v6 < v7)
        #expect(v7 < v8)
        #expect(v8 > v1)
    }

    @Test
    func losslessStringConvertible() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v2 = Version(major: 1, prerelease: "beta")
        let v3 = Version(major: 2, metadata: "exp", "test")
        let v4 = Version(major: 2)
        let v5 = Version(major: 2, metadata: "abc-1")
        let v6 = Version(major: 22, minor: 33, metadata: "abc-1")
        let v7 = Version(major: 1, minor: 1)
        let v8 = Version(major: 3)

        let v1FromString = Version(String(describing: v1))
        let v2FromString = Version(String(describing: v2))
        let v3FromString = Version(String(describing: v3))
        let v4FromString = Version(String(describing: v4))
        let v5FromString = Version(String(describing: v5))
        let v6FromString = Version(String(describing: v6))
        let v7FromString = Version(v7.versionString(formattedWith: .dropTrailingZeros))
        let v8FromString = Version(v8.versionString(formattedWith: .dropTrailingZeros))

        #expect(v1FromString != nil)
        #expect(v2FromString != nil)
        #expect(v3FromString != nil)
        #expect(v4FromString != nil)
        #expect(v5FromString != nil)
        #expect(v6FromString != nil)
        #expect(v7FromString != nil)
        #expect(v8FromString != nil)

        // We need to compare metadata manually here, since it's not considered in equality check
        #expect(v1 == v1FromString)
        #expect(v1.metadata == v1FromString?.metadata)
        #expect(v2 == v2FromString)
        #expect(v2.metadata == v2FromString?.metadata)
        #expect(v3 == v3FromString)
        #expect(v3.metadata == v3FromString?.metadata)
        #expect(v4 == v4FromString)
        #expect(v4.metadata == v4FromString?.metadata)
        #expect(v5 == v5FromString)
        #expect(v5.metadata == v5FromString?.metadata)
        #expect(v6 == v6FromString)
        #expect(v6.metadata == v6FromString?.metadata)
        #expect(v7 == v7FromString)
        #expect(v7.metadata == v7FromString?.metadata)
        #expect(v8 == v8FromString)
        #expect(v8.metadata == v8FromString?.metadata)
    }

    @Test
    func customDebugStringRepresentable() {
        let v1 = Version(major: 1)
        let v2 = Version(major: 1, minor: 2)
        let v3 = Version(major: 1, minor: 2, patch: 3)
        let v4 = Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp", "test")
        let v5 = Version(major: 1, prerelease: "beta")
        let v6 = Version(major: 1, metadata: "exp", "test")

        #expect(v1.debugDescription == #"Version(major: 1, minor: 0, patch: 0, prerelease: "", metadata: "")"#)
        #expect(v2.debugDescription == #"Version(major: 1, minor: 2, patch: 0, prerelease: "", metadata: "")"#)
        #expect(v3.debugDescription == #"Version(major: 1, minor: 2, patch: 3, prerelease: "", metadata: "")"#)
        #expect(v4.debugDescription == #"Version(major: 1, minor: 2, patch: 3, prerelease: "beta", metadata: "exp.test")"#)
        #expect(v5.debugDescription == #"Version(major: 1, minor: 0, patch: 0, prerelease: "beta", metadata: "")"#)
        #expect(v6.debugDescription == #"Version(major: 1, minor: 0, patch: 0, prerelease: "", metadata: "exp.test")"#)
    }

    @Test
    func hashable() {
        let v1 = Version(major: 1, minor: 2, patch: 3, prerelease: ["beta"], metadata: "exp", "test")
        let v2 = Version(major: 1, minor: 2, patch: 3, prerelease: ["beta"])
        let v3 = Version(major: 3)

        let v1Hash: Int = {
            var hasher = Hasher()
            hasher.combine(v1.major)
            hasher.combine(v1.minor)
            hasher.combine(v1.patch)
            hasher.combine(v1.prerelease)
            return hasher.finalize()
        }()
        let v2Hash: Int = {
            var hasher = Hasher()
            hasher.combine(v2.major)
            hasher.combine(v2.minor)
            hasher.combine(v2.patch)
            hasher.combine(v2.prerelease)
            return hasher.finalize()
        }()
        let v3Hash: Int = {
            var hasher = Hasher()
            hasher.combine(v3.major)
            hasher.combine(v3.minor)
            hasher.combine(v3.patch)
            hasher.combine(v3.prerelease)
            return hasher.finalize()
        }()

        #expect(v1.hashValue == v1Hash)
        #expect(v2.hashValue == v2Hash)
        #expect(v3.hashValue == v3Hash)
    }

    @Test
    func modifying() {
        var version = Version(major: 1)
        version.major = 2
        version.minor = 1
        version.patch = 3
        version.prerelease = ["beta"]
        version.metadata = ["yea", "testing", "rocks"]

        let expectedVersion = Version(major: 2, minor: 1, patch: 3, prerelease: ["beta"], metadata: "yea", "testing", "rocks")
        #expect(version == expectedVersion)
        #expect(version.versionString(formattedWith: .fullVersion) == expectedVersion.versionString(formattedWith: .fullVersion))
    }

    @Test
    func invalidStrings() {
        #expect(Version("") == nil)
        #expect(Version("1.2.3.4") == nil)
        #expect(Version("ABC") == nil)
        #expect(Version("-1.2.0") == nil)
        #expect(Version("🥴") == nil)
    }

    @Test
    func macro() {
        let macroVersion = #version("1.2.3-alpha.1.-2+exp.test")
        #expect(macroVersion == Version(major: 1, minor: 2, patch: 3, prerelease: "alpha", 1, -2, metadata: ["exp", "test"]))
    }

    /*
     @Test
     func stringLiteralConversion() {
         #expect("1.2.3" == Version(major: 1, minor: 2, patch: 3))
         #expect("1.2.3-rc1+exp-1.test" == Version(major: 1, minor: 2, patch: 3, prerelease: "rc1", metadata: "exp-1", "test"))
         #expect("1.2.3+exp-1.test" == Version(major: 1, minor: 2, patch: 3, metadata: "exp-1", "test"))
     }
     */
}
