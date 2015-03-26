# Sandbox

**Sandbox** aims to hide the awkward logistics required to let your app access files outside its own scope behind a simple and sane closure-based synchronous API, while keeping you in full control over your app's logical flow.

## Features

**Sandbox** provides functions for…

- Checking whether a given resource is currently accessible from your app:
```swift
func needsPermissionForFileAtURL(fileURL: NSURL, error: NSErrorPointer = nil) -> Bool
```

- Asking the user for a security scope for a given resource:
```swift
func askUserForSecurityScopeForFileAtURL(fileURL: NSURL, error: NSErrorPointer = nil) -> NSURL?
```

- Handling the error-prone access-management for a security scoped resource:
```swift
func accessSecurityScopedFileAtURL(fileURL: NSURL, closure: () -> ()) -> Bool
```

- And last but not least a hassle-free all-in-one function for when your *"just want to access that effin' file"*:
```swift
func accessAndIfNeededAskUserForSecurityScopeForFileAtURL(fileURL: NSURL, closure: () -> ()) -> Bool
```

### Example usage

#### Single-file access

```swift
let permissionManager = PermissionManager.defaultManager
permissionManager.accessAndIfNeededAskUserForSecurityScopeForFileURL(fileURL) {
    // read/write fileURL
}
```

#### Multi-file access

At some point your app may have to **access dozens if not hundreds of files** from potentially **different directories** (or even **disk volumes**).
Accessing one file after another (and by that potentially having to ask the user for their permission) is **clumsy** and will **annoy the user** rather quickly.

**Sandbox** provides a convenience function for this very scenario:

```swift
func NSURL.groupByCommonPrefixURLs_sbx([NSURL]) -> ([NSURL: [NSURL]])`
```

It figures out the optimal grouping of resources based on their file paths and as such allows you to reduce number of permission dialogs to the very minimum, like so:

```swift
let permissionManager = PermissionManager.defaultManager
	for (groupCommonFileURL, groupFileURLs) in NSURL.groupByCommonPrefixURLs_sbx(fileURLs) {
	permissionManager.accessAndIfNeededAskUserForSecurityScopeForFileURL(groupCommonFileURL) {
		for fileURL in groupFileURLs {
			// read/write fileURL
		}
	}
}
```

## Demos

**Sandbox** contains a demo app.
*(Note: Make sure to either type in or copy&paste file paths into its text field as with drag&drop the operating system will automatically create a security scope for you.)*

## Installation

Just copy the files in `"Sandbox/Classes/..."` into your project.

Alternatively you can install **Sandbox** into your project with [Carthage](https://github.com/Carthage/Carthage) (`github 'regexident/Sandbox'`) or with [CocoaPods](http://cocoapods.org/) (`pod 'Sandbox'`)

## Swift

**Sandbox** is implemented in 100% Swift.

## Dependencies

None.

## Requirements.

OS X 10.9+

## Creator

Vincent Esche ([@regexident](http://twitter.com/regexident))

## License

**Sandbox** is available under a **modified BSD-3 clause license** with the **additional requirement of attribution**. See the `LICENSE` file for more info.
