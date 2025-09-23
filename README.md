# SemVer

[![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/semver.svg?style=flat)](https://github.com/sersoft-gmbh/semver/releases/latest)
![Tests](https://github.com/sersoft-gmbh/semver/workflows/Tests/badge.svg)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/d36d463d4085404b914e5c5ffd45a725)](https://www.codacy.com/gh/sersoft-gmbh/semver/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/semver&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/sersoft-gmbh/semver/branch/main/graph/badge.svg)](https://codecov.io/gh/sersoft-gmbh/semver)
[![Docs](https://img.shields.io/badge/-documentation-informational)](https://sersoft-gmbh.github.io/semver)

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

## Documentation

The API is documented using header doc. If you prefer to view the documentation as a webpage, there is an [online version](https://sersoft-gmbh.github.io/semver) available for you.

## Contributing

If you find a bug / like to see a new feature in SemVer there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR!
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can't do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.
