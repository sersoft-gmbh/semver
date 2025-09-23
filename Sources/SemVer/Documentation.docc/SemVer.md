# ``SemVer``

A complete implementation of a `Version` struct that conforms to the rules of semantic versioning which are described at [semver.org](https://semver.org).

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/semver", from: "5.0.0"),
```

## Compatibility

| **Swift**          | **SemVer Package**  |
|--------------------|---------------------|
| <  5.3.0           | 1.x.y - 2.x.y       |
| >= 5.3.0, < 5.9.0  | 3.x.y               |
| >= 5.9.0           | 5.x.y               |


## Usage

### Creating Versions

You can create a version like this:

```swift
let version = Version(major: 1, minor: 2, patch: 3,
                      prerelease: "beta", 1, // prerelease could also be ["beta", 1]
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

And there is also a Swift [macro](#macros) for statically creating versions.

### Version Strings

As seen in above's examples, there's a func to return a string represenation of a ``Version``. The `versionString(formattedWith options: FormattingOptions = default)` function allows to retrieve a formatted string using the options passed. By default the full version is returned.
The following options currently exist:

-   ``Version/FormattingOptions/dropPatchIfZero``: If ``Version/patch`` is `0`, it won't be added to the version string.
-   ``Version/FormattingOptions/dropMinorIfZero``: If ``Version/minor`` and ``Version/patch`` are both `0`, only the `major` number is added. Requires ``Version/FormattingOptions/dropPatchIfZero``.
-   ``Version/FormattingOptions/dropTrailingZeros``: A convenience combination of ``Version/FormattingOptions/dropMinorIfZero`` and ``Version/FormattingOptions/dropPatchIfZero``.
-   ``Version/FormattingOptions/includePrerelease``: If ``Version/prerelease`` is not empty, it is added to the version string.
-   ``Version/FormattingOptions/includeMetadata``: If ``Version/metadata`` is not empty, it is added to the version string.
-   ``Version/FormattingOptions/fullVersion``: A convenience combination of ``Version/FormattingOptions/includePrerelease`` and ``Version/FormattingOptions/includeMetadata``. The default if you don't pass any options to ``Version/versionString(formattedWith:)``.

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

A ``Version`` can also be created from a String. All Strings created by ``Version/versionString(formattedWith:)`` should result in the same ``Version`` they were created from:

```swift
let version = Version(major: 1, minor: 2, patch: 3,
                      prerelease: "beta",
                      metadata: "exp", "test")
let str = version.versionString() // -> "1.2.3-beta+exp.test"
let recreatedVersion = Version(str) // recreatedVersion is Optional<Version>
recreatedVersion == version // -> true
```

### Comparing Versions

A ``Version`` can also be compared to other versions. This also follows the rules of semantic versioning. This means that ``Version/metadata`` has no effect on comparing at all. This also means that a version with and without metadata are **treated as equal**:

```swift
let versionWithMetadata = Version(major: 1, minor: 2, patch: 3,
                                  metadata: "exp", "test")
let versionWithoutMetadata = Version(major: 1, minor: 2, patch: 3)
versionWithMetadata == versionWithoutMetadata // -> true
```

Otherwise, comparing two ``Version``'s basically compares their major/minor/patch numbers. A ``Version`` with ``Version/prerelease`` identifiers is ordered **before** a the same version without ``Version/prerelease`` identifiers:

```swift
let preReleaseVersion = Version(major: 1, minor: 2, patch: 3,
                                prerelease: "beta")
let finalVersion = Version(major: 1, minor: 2, patch: 3)
preReleaseVersion < finalVersion // -> true
```

If you need to check whether two versions are completely identical, there's the ``Version/isIdentical(to:requireIdenticalMetadataOrdering:)`` method, which also checks ``Version/metadata``.

### Validity Checks

``Version`` performs some validity checks on its fields. This means, that no negative numbers are allowed for ``Version/major``, ``Version/minor`` and ``Version/patch``. Also, the ``Version/prerelease`` and ``Version/metadata`` Strings must only contain alphanumeric characters plus `-` (hyphen). However, to keep working with ``Version`` production-safe, these rules are only checked in non-optimized builds (using `assert()`). The result of using not allowed numbers / characters in optimized builds is undetermined. While calling ``Version/versionString(formattedWith:)`` very likely won't break, it certainly won't be possible to recreate a version containing invalid numbers / characters using ``Version/init(_:)``.

### Codable

``Version`` conforms to `Codable`! The encoding / decoding behavior can be controlled by using ``Swift/CodingUserInfoKey/versionEncodingStrategy`` and ``Swift/CodingUserInfoKey/versionDecodingStrategy``. For `JSONEncoder`/`JSONDecoder` and `PropertyListEncoder`/`PropertyListDecoder`, there are the convenience properties `semverVersionEncodingStrategy`/`semverVersionDecodingStrategy` in place:

-   ``Foundation/JSONEncoder/semverVersionEncodingStrategy``
-   ``Foundation/JSONDecoder/semverVersionDecodingStrategy``
-   ``Foundation/PropertyListEncoder/semverVersionEncodingStrategy``
-   ``Foundation/PropertyListDecoder/semverVersionDecodingStrategy``

### Macros

This package also provides a `SemVerMacros` product. It's a separate product, so that SwiftSyntax won't be compiled for users of SemVer if no macro is actually needed.
If a `Version` should be constructed from a `String` that is known at compile time, the `#version` macro can be used. It will parse the `String` at compile time and generate code that initializes a `Version` from the result:

```swift
let version = #version("1.2.3")
```

results in

```swift
let version = Version(major: 1, minor: 2, patch: 3, prerelase: [], metadata: [])
```

