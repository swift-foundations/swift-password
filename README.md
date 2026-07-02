# swift-password-validation

[![CI](https://github.com/swift-foundations/swift-password/workflows/CI/badge.svg)](https://github.com/swift-foundations/swift-password/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Password validation library for Swift with composable rules and localized error messages.

## Overview

PasswordValidation provides type-safe password validation in Swift. It includes predefined validation rules and supports custom validation logic through dependency injection.

## Features

- Predefined validators for common password requirements
- Custom validation logic via closure-based composition
- Dependencies library integration for testability
- Localized error messages in English and Dutch
- Sendable conformance for Swift concurrency

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-password.git", from: "0.0.1")
]
```

Then add `PasswordValidation` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "PasswordValidation", package: "swift-password-validation")
    ]
)
```

## Quick Start

### Basic Usage

```swift
import PasswordValidation

// Use the default validator
let validator = PasswordValidation.default

do {
    let isValid = try validator.validate("MySecurePass123!")
    print("Password is valid: \(isValid)")
} catch let error as PasswordValidation.Error {
    print("Validation failed: \(error.description)")
}
```

### With Dependencies

```swift
import Dependencies
import PasswordValidation

struct LoginService {
    @Dependency(\.passwordValidation) var passwordValidation

    func validateUserPassword(_ password: String) throws -> Bool {
        return try passwordValidation.validate(password)
    }
}
```

## Usage Examples

### Default Validator

The `default` validator implements standard security requirements:

- Length: 8-64 characters
- Uppercase: At least one uppercase letter (A-Z)
- Lowercase: At least one lowercase letter (a-z)
- Digits: At least one digit (0-9)
- Special Characters: At least one special character (`!&^%$#@()/`)

```swift
let validator = PasswordValidation.default
try validator.validate("MySecurePass123!") // Returns true
```

### Simple Validator

The `simple` validator requires only 4+ characters:

```swift
let validator = PasswordValidation.simple
try validator.validate("test") // Returns true
```

### Custom Validation

Create your own validation rules:

```swift
let customValidator = PasswordValidation { password in
    guard password.count >= 6 else {
        throw PasswordValidation.Error.tooShort(minLength: 6)
    }

    guard !password.lowercased().contains("password") else {
        throw PasswordValidation.Error.missingSpecialCharacter
    }

    return true
}
```

### Error Handling

The library provides specific error types for different validation failures:

```swift
do {
    try PasswordValidation.default.validate("weak")
} catch PasswordValidation.Error.tooShort(let minLength) {
    print("Password too short, needs at least \(minLength) characters")
} catch PasswordValidation.Error.missingUppercase {
    print("Password needs an uppercase letter")
} catch PasswordValidation.Error.missingDigit {
    print("Password needs a digit")
} catch {
    print("Other validation error: \(error)")
}
```

### Available Errors

- `tooShort(minLength: Int)` - Password is shorter than required
- `tooLong(maxLength: Int)` - Password exceeds maximum length
- `missingUppercase` - No uppercase letters found
- `missingLowercase` - No lowercase letters found
- `missingDigit` - No digits found
- `missingSpecialCharacter` - No special characters found

## Related Packages

### Dependencies

- [swift-translating](https://github.com/swift-foundations/swift-translating): A Swift package for inline translations.

### Used By

- [coenttb-web](https://github.com/coenttb/coenttb-web): A Swift package with tools for web development building on swift-web.
- [swift-server-foundation](https://github.com/coenttb/swift-server-foundation): A Swift package with tools to simplify server development.

### Third-Party Dependencies

- [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies): A dependency management library for controlling dependencies in Swift.

## License

This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.
