# ``SemVerMacros``

Compile-time version string parsing.

### Macros

If a `Version` should be constructed from a `String` that is known at compile time, the ``version(_:)`` macro can be used.
It will parse the `String` at compile time and generate code that initializes a `Version` from the result:

```swift
let version = #version("1.2.3")
```

expands to

```swift
let version = SemVer.Version(major: 1, minor: 2, patch: 3, prerelase: [], metadata: [])
```
