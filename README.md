# DEPRECATED

This library is now deprecated in favour of a more complete and SwiftUI friendly `TextEditor` backport:

https://github.com/shaps80/SwiftUIBackports
> See it in action here: https://twitter.com/shaps/status/1654972428286668800?s=20

![TextEditor Backport](https://pbs.twimg.com/media/FvekWp2XwAICDRq?format=jpg&name=large)

---

# TextView

> Also available as a part of my [SwiftUI+ Collection](https://benkau.com/packages.json) – just add it to Xcode 13+

Provides a SwiftUI multi-line TextView implementation with support for iOS v13+

## WIP

-   [ ] Improved formatting support

## Features

-   Configure all properties via modifiers
-   Multi-line text
-   Placeholder
-   No predefined design, full-flexibility to design in Swift UI
-   UIFont extensions to give you SwiftUI Font APIs
-   Auto-sizes height to fit content as you type

## Example

```swift
TextView($text)
    .placeholder("Enter some text") { view in
        view.foregroundColor(.gray)
    }
    .padding(10)
    .overlay(
        RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 1)
            .foregroundColor(Color(.placeholderText))
    )
    .padding()
```

## Installation

The code is packaged as a framework. You can install manually (by copying the files in the `Sources` directory) or using Swift Package Manager (**preferred**)

To install using Swift Package Manager, add this to the `dependencies` section of your `Package.swift` file:

`.package(url: "https://github.com/SwiftUI-Plus/TextView.git", .upToNextMinor(from: "1.0.0"))`

## Other Packages

If you want easy access to this and more packages, add the following collection to your Xcode 13+ configuration:

`https://benkau.com/packages.json`
