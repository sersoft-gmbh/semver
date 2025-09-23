import Testing
import SemVer

extension VersionTests {
    @Suite
    struct AdjustmentTests {
        @Test
        func versionNumericPartDescription() {
            #expect(String(describing: Version.NumericPart.major) == "major")
            #expect(String(describing: Version.NumericPart.minor) == "minor")
            #expect(String(describing: Version.NumericPart.patch) == "patch")
        }

        @Test
        func nextVersion() {
            let prerelease: Array<Version.PrereleaseIdentifier> = ["beta", 42]
            let metadata = ["abc", "def"]
            let version = Version(major: 1, minor: 2, patch: 3, prerelease: prerelease, metadata: metadata)

            #expect(version.next(.major) == Version(major: 2))
            #expect(version.next(.minor) == Version(major: 1, minor: 3))
            #expect(version.next(.patch) == Version(major: 1, minor: 2, patch: 4))
            #expect(version.next(.major).metadata.isEmpty)
            #expect(version.next(.minor).metadata.isEmpty)
            #expect(version.next(.patch).metadata.isEmpty)
            #expect(version.next(.major, keepingPrerelease: true) == Version(major: 2, prerelease: prerelease))
            #expect(version.next(.minor, keepingPrerelease: true) == Version(major: 1, minor: 3, prerelease: prerelease))
            #expect(version.next(.patch, keepingPrerelease: true) == Version(major: 1, minor: 2, patch: 4, prerelease: prerelease))
            #expect(version.next(.major, keepingPrerelease: true).metadata.isEmpty)
            #expect(version.next(.minor, keepingPrerelease: true).metadata.isEmpty)
            #expect(version.next(.patch, keepingPrerelease: true).metadata.isEmpty)
            #expect(version.next(.major, keepingMetadata: true) == Version(major: 2))
            #expect(version.next(.minor, keepingMetadata: true) == Version(major: 1, minor: 3))
            #expect(version.next(.patch, keepingMetadata: true) == Version(major: 1, minor: 2, patch: 4))
            #expect(version.next(.major, keepingMetadata: true).metadata == metadata)
            #expect(version.next(.minor, keepingMetadata: true).metadata == metadata)
            #expect(version.next(.patch, keepingMetadata: true).metadata == metadata)
        }

        @Test
        func versionIncrease() {
            let prerelease: Array<Version.PrereleaseIdentifier> = ["beta", 42]
            let metadata = ["abc", "def"]
            let version = Version(major: 1, minor: 2, patch: 3, prerelease: prerelease, metadata: metadata)

            var mutatingVersion = version
            mutatingVersion.increase(.major)
            #expect(mutatingVersion == Version(major: 2))
            #expect(mutatingVersion.metadata.isEmpty)
            mutatingVersion = version
            mutatingVersion.increase(.minor)
            #expect(mutatingVersion == Version(major: 1, minor: 3))
            #expect(mutatingVersion.metadata.isEmpty)

            mutatingVersion = version
            mutatingVersion.increase(.patch)
            #expect(mutatingVersion == Version(major: 1, minor: 2, patch: 4))
            #expect(mutatingVersion.metadata.isEmpty)

            mutatingVersion = version
            mutatingVersion.increase(.major, keepingPrerelease: true)
            #expect(mutatingVersion == Version(major: 2, prerelease: prerelease))
            #expect(mutatingVersion.metadata.isEmpty)

            mutatingVersion = version
            mutatingVersion.increase(.major, keepingMetadata: true)
            #expect(mutatingVersion == Version(major: 2))
            #expect(mutatingVersion.metadata == metadata)

            mutatingVersion = version
            mutatingVersion.increase(.minor, keepingMetadata: true)
            #expect(mutatingVersion == Version(major: 1, minor: 3))
            #expect(mutatingVersion.metadata == metadata)

            mutatingVersion = version
            mutatingVersion.increase(.patch, keepingMetadata: true)
            #expect(mutatingVersion == Version(major: 1, minor: 2, patch: 4))
            #expect(mutatingVersion.metadata == metadata)
        }
    }
}
