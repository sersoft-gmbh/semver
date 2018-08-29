# SemVer
![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/semver.svg?style=flat)
![CI Status](https://travis-ci.com/sersoft-gmbh/SemVer.svg?branch=master)

This repository contains a complete implementation of a `Version` struct that conforms to the rules of semantic versioning which are described at [semver.org](https://semver.org).

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/semver.git", from: "2.0.0"),
```

## Usage

### Creating Versions

You can create a version like this:

```swift
let version = Version(major: 1, minor: 2, patch: 3,
                      prerelease: "beta",
                      metadata: "exp", "test") // metadata could also be ["exp, test"]
version.versionString() // -> "1.2.3-beta+exp.test"
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

- `.dropPatchIfZero`: If `patch` is `0`, it won't be added to the version string.
- `.dropMinorIfZero`: If `minor` and `patch` are both `0`, only the `major` number is added. Requires `.dropPatchIfZero`.
- `.dropTrailingZeros`: A convenience combination of `.dropPatchIfZero` and `.dropMinorIfZero`.
- `.includePrerelease`: If `prerelease` is not empty, it is added to the version string.
- `.includeMetadata`: If `metadata` is not empty, it is added to the version string.
- `.fullVersion`: A convenience combination of `.includePrerelease` and `.includeMetadata`. The default if you don't pass anything to `versionString`.

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

Otherwise, comparing two `Version`'s basically compares their major/minor/patch numbers. A `Version` with a `prerelease` is ordered **before** a the same version without `prerelease`:

```swift
let prereleaseVersion = Version(major: 1, minor: 2, patch: 3,
                                prerelease: "beta")
let finalVersion = Version(major: 1, minor: 2, patch: 3)
prereleaseVersion < finalVersion // -> true
```

### Validity Checks

`Version` performs some validity checks on its fields. This means, that no negative numbers are allowed for `major`, `minor` and `patch`. Also, the `prerelease` and `metadata` Strings must only contain alphanumeric characters plus `-` (hyphen). However, to keep working with `Version` production-safe, these rules are only checked in non-optimized builds (using `assert()`). The result of using not allowed numbers / characters in optimized builds is undetermined. While calling `versionString()` very likely won't break, it certainly won't be possible to recreate a version containing invalid numbers / characters using `init(_ description: String)`.


## Contributing

If you find a bug / like to see a new feature in SemVer there are a few ways of helping out:

- If you can fix the bug / implement the feature yourself please do and open a PR!
- If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
- If you can't do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.

