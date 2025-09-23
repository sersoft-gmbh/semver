import Testing
import SemVerParsing
@testable import SemVer

extension VersionTests {
    @Suite
    struct PrereleaseIdentifierTests {
        @Test
        func description() {
            let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
            let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

            #expect(prereleaseIdentifierText.description == prereleaseIdentifierText.string)
            #expect(prereleaseIdentifierNumber.description == prereleaseIdentifierNumber.string)
        }

        @Test
        func debugDescription() {
            let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
            let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

            #expect(prereleaseIdentifierText.debugDescription == "text(\(prereleaseIdentifierText.string))")
            #expect(prereleaseIdentifierNumber.debugDescription == "number(\(prereleaseIdentifierNumber.string))")
        }

        @Test
        func string() {
            let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
            let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

            #expect(prereleaseIdentifierText.string == "test")
            #expect(prereleaseIdentifierNumber.string == "1")
        }

        @Test
        func number() {
            let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
            let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)

            #expect(prereleaseIdentifierText.number == nil)
            #expect(prereleaseIdentifierNumber.number == 1)
        }

        @Test
        func creation() {
            let prereleaseIdentifierText = Version.PrereleaseIdentifier.string("test")
            let prereleaseIdentifierNumber = Version.PrereleaseIdentifier.number(1)
            let prereleaseIdentifierNumberFromText = Version.PrereleaseIdentifier.string("42")
            let prereleaseIdentifierUncheckedText = Version.PrereleaseIdentifier(unchecked: "abc")

            #expect(prereleaseIdentifierText._storage == .text("test"))
            #expect(prereleaseIdentifierNumber._storage == .number(1))
            #expect(prereleaseIdentifierNumberFromText._storage == .number(42))
            #expect(prereleaseIdentifierUncheckedText._storage == .text("abc"))
        }

        @Test
        func creationFromLiterals() {
            let prereleaseIdentifierText: Version.PrereleaseIdentifier = "test"
            let prereleaseIdentifierNumber: Version.PrereleaseIdentifier = 1
            let prereleaseIdentifierNumberFromText: Version.PrereleaseIdentifier = "42"

            #expect(prereleaseIdentifierText._storage == .text("test"))
            #expect(prereleaseIdentifierNumber._storage == .number(1))
            #expect(prereleaseIdentifierNumberFromText._storage == .number(42))
        }

        @Test
        func comparison() {
            let textABC: Version.PrereleaseIdentifier = "abc"
            let textDEF: Version.PrereleaseIdentifier = "def"
            let num42: Version.PrereleaseIdentifier = 42
            let num142: Version.PrereleaseIdentifier = 142

            #expect(textABC < textDEF)

            #expect(num42 < num142)

            #expect(num42 < textABC)
            #expect(num42 < textDEF)
            #expect(num142 < textABC)
            #expect(num142 < textDEF)

            #expect(!(textABC < num42))
            #expect(!(textDEF < num42))
            #expect(!(textABC < num142))
            #expect(!(textDEF < num142))
        }
    }
}
