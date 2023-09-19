# SemVer
[![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/semver.svg?style=flat)](https://github.com/sersoft-gmbh/semver/releases/latest)
![Tests](https://github.com/sersoft-gmbh/semver/workflows/Tests/badge.svg)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/d36d463d4085404b914e5c5ffd45a725)](https://www.codacy.com/gh/sersoft-gmbh/semver/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/semver&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/sersoft-gmbh/semver/branch/main/graph/badge.svg)](https://codecov.io/gh/sersoft-gmbh/semver)
[![Docs](https://img.shields.io/badge/-documentation-informational)](https://sersoft-gmbh.github.io/semver)

This repository contains a complete implementation of a `Version` struct that conforms to the rules of semantic versioning which are described at [semver.org](https://semver.org).

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/semver.git", from: "4.0.0"),
```

## Compatibility

-  For Swift up to version 5.2, use SemVer version 2.x.y.
-  For Swift up to version 5.8, use SemVer version 3.x.y.
-  For Swift as of version 5.9, use SemVer version 4.x.y.

## Usage

### Creating Versions

You can create a version like this:

```swift
let version = Version(major: 1, minor: 2, patch: 3,
                      prerelease: "beta", "1", // prerelease could also be ["beta", "1"]
                      metadata: "exp", "test") // metadata could also be ["exp, test"]
version.versionString() // -> "1.2.3-beta.1+exp.test"
```

Of course there are simpler ways:

```swift
let initialRelease = Version(major: 1)
initialRelease.versionString() // -> "1.0.0"

let minorRelease = Version(major: 2, minor: 1)
minorRelease.versionString() // -> "2.1.0"

let patchRelease = Version(major: 3, minor: 2, patch: 1)
patchRelease.versionString() // -> "3.2.1"
```

### Version Strings

As seen in above's examples, there's a func to return a string represenation of a `Version`. The `versionString(formattedWith options: FormattingOptions = default)` function allows to retrieve a formatted string using the options passed. By default the full version is returned.
The following options currently exist:

-   `.dropPatchIfZero`: If `patch` is `0`, it won't be added to the version string.
-   `.dropMinorIfZero`: If `minor` and `patch` are both `0`, only the `major` number is added. Requires `.dropPatchIfZero`.
-   `.dropTrailingZeros`: A convenience combination of `.dropPatchIfZero` and `.dropMinorIfZero`.
-   `.includePrerelease`: If `prerelease` are not empty, they are added to the version string.
-   `.includeMetadata`: If `metadata` is not empty, it is added to the version string.
-   `.fullVersion`: A convenience combination of `.includePrerelease` and `.includeMetadata`. The default if you don't pass anything to `versionString`.

```swift
let version = Version(major: 1, minor: 2, patch: 3,
                      prerelease: "beta",
                      metadata: "exp", "test")
version.versionString(formattedWith: .includePrerelease]) // -> "1.2.3-beta"
version.versionString(formattedWith: .includeMetadata) // -> "1.2.3+exp.test"
version.versionString(formattedWith: []) // -> "1.2.3"

let version2 = Version(major: 2)
version2.versionString(formattedWith: .dropPatchIfZero) // -> "2.0"
version2.versionString(formattedWith: .dropTrailingZeros) // -> "2"
```

A `Version` can also be created from a String. All Strings created by the `versionString` func should result in the same `Version` they were created from:

```swift
let version = Version(major: 1, minor: 2, patch: 3,
                      prerelease: "beta",
                      metadata: "exp", "test")
let str = version.versionString() // -> "1.2.3-beta+exp.test"
let recreatedVersion = Version(str) // recreatedVersion is Optional<Version>
recreatedVersion == version // -> true
```

### Comparing Versions

A `Version` can also be compared to other versions. This also follows the rules of semantic versioning. This means that `metadata` has no effect on comparing at all. This also means that a version with and without metadata are **treated as equal**:

```swift
let versionWithMetadata = Version(major: 1, minor: 2, patch: 3,
                                  metadata: "exp", "test")
let versionWithoutMetadata = Version(major: 1, minor: 2, patch: 3)
versionWithMetadata == versionWithoutMetadata // -> true
```

Otherwise, comparing two `Version`'s basically compares their major/minor/patch numbers. A `Version` with `prerelease` identifiers is ordered **before** a the same version without `prerelease` identifiers:

```swift
let preReleaseVersion = Version(major: 1, minor: 2, patch: 3,
                                prerelease: "beta")
let finalVersion = Version(major: 1, minor: 2, patch: 3)
preReleaseVersion < finalVersion // -> true
```

If you need to check whether two versions are completely identical, there's the `isIdentical(to:)` method, which also checks `metadata`.

### Validity Checks

`Version` performs some validity checks on its fields. This means, that no negative numbers are allowed for `major`, `minor` and `patch`. Also, the `prerelease` and `metadata` Strings must only contain alphanumeric characters plus `-` (hyphen). However, to keep working with `Version` production-safe, these rules are only checked in non-optimized builds (using `assert()`). The result of using not allowed numbers / characters in optimized builds is undetermined. While calling `versionString()` very likely won't break, it certainly won't be possible to recreate a version containing invalid numbers / characters using `init(_ description: String)`.

### Codable

`Version` conforms to `Codable`! The encoding / decoding behavior can be controlled by using the `.versionEncodingStrategy` and `.versionDecodingStrategy` `CodingUserInfoKey`s. For `JSONEncoder`/`JSONDecoder` and `PropertyListEncoder`/`PropertyListDecoder`, there are the convenience properties `semverVersionEncodingStrategy`/`semverVersionDecodingStrategy` in place.

### Macros

If a `Version` should be constructed from a `String` that is known at compile time, the `#version` macro can be used. It will parse the `String` at compile time and generate code that initializes a version from the result. 

## Documentation

The API is documented using header doc. If you prefer to view the documentation as a webpage, there is an [online version](https://sersoft-gmbh.github.io/SemVer) available for you.

## Contributing

If you find a bug / like to see a new feature in SemVer there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR!
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can't do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License & Copyright

See [LICENSE](./LICENSE) file.

Copyright &copy; 2016-2023 ser.soft GmbH.
