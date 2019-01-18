import XCTest

extension VersionTests {
    static let __allTests = [
        ("testDescriptionIsEqualToFullVersionString", testDescriptionIsEqualToFullVersionString),
        ("testFullVersionString", testFullVersionString),
        ("testFullVersionStringWithoutPrereleaseDataWithMetadataData", testFullVersionStringWithoutPrereleaseDataWithMetadataData),
        ("testFullVersionStringWithPrereleaseDataWithoutMetadataData", testFullVersionStringWithPrereleaseDataWithoutMetadataData),
        ("testFullVersionStringWithSuffixWithoutData", testFullVersionStringWithSuffixWithoutData),
        ("testHashable", testHashable),
        ("testInvalidStrings", testInvalidStrings),
        ("testLosslessStringConvertible", testLosslessStringConvertible),
        ("testModifying", testModifying),
        ("testVersionComparisonWithBasicVersion", testVersionComparisonWithBasicVersion),
        ("testVersionEqualityWithBasicVersion", testVersionEqualityWithBasicVersion),
        ("testVersionEqualityWithMetadataDifference", testVersionEqualityWithMetadataDifference),
        ("testVersionStringExcludingMetadata", testVersionStringExcludingMetadata),
        ("testVersionStringExcludingPrerelease", testVersionStringExcludingPrerelease),
        ("testVersionStringWhenDroppingZeros", testVersionStringWhenDroppingZeros),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VersionTests.__allTests),
    ]
}
#endif
