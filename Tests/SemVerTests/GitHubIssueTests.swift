import Testing
import SemVer

@Suite
struct GitHubIssueTests {
    @Test(.bug("https://github.com/sersoft-gmbh/semver/issues/107", id: 107))
    func gh107() throws {
        let version = try #require(Version("1.0.0-beta.11"))
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)
        #expect(version.prerelease == ["beta", "11"])
    }
}
