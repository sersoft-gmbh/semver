import XCTest

import SemVerTests

var tests = [XCTestCaseEntry]()
tests += SemVerTests.__allTests()

XCTMain(tests)
