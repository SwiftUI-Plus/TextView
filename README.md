# TextView

Provides a SwiftUI multi-line TextView implementation with support for iOS v13+

## WIP

- [ ] Improved formatting support
 

## Features

- Configure all properties via modifiers
- Multi-line text
- Placeholder
- No predefined design, full-flexibility to design in Swift UI
- UIFont extensions to give you SwiftUI Font APIs
- Auto-sizes height to fit content as you type

## Example

```swift
TextView("Placeholder", text: $text, onCommit: commit)
    .font(.system(.body, design: .rounded))
    .border(Color.gray, width: 1)
    .padding()
```

## Installation

The code is packaged as a framework. You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (__preferred__)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/SwiftUI-Plus/TextView.git", .upToNextMinor(from: "1.0.0"))`

## Other Packages

If you want easy access to this and more packages, add the following collection to your Xcode 13+ configuration:

`https://benkau.com/packages.json`
