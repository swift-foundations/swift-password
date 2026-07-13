import Translating
import Translating_Dependencies

/// A password validation system that provides flexible validation rules.
///
/// `PasswordValidation` allows you to define custom password validation logic
/// that can be used throughout your application. It provides both predefined
/// validation rules and the ability to create custom validators.
///
/// ## Usage
///
/// ```swift
/// let validator = PasswordValidation.default
/// do {
///     let isValid = try validator.validate("MyPassword123!")
///     print("Password is valid: \(isValid)")
/// } catch {
///     print("Validation failed: \(error)")
/// }
/// ```
public struct PasswordValidation: Sendable {
  /// The validation closure that takes a password string and returns whether it's valid.
  ///
  /// - Parameter password: The password to validate
  /// - Returns: `true` if the password is valid
  /// - Throws: A ``PasswordValidation/Error`` if validation fails

  public var validate: @Sendable (_ password: String) throws -> Bool

  /// Creates a new password validator with custom validation logic.
  ///
  /// - Parameter validate: A closure that defines the validation rules
  public init(validate: @Sendable @escaping (_: String) throws -> Bool) {
    self.validate = validate
  }
}

extension PasswordValidation {
  public func callAsFunction(_ password: String) throws -> Bool {
    try self.validate(password)
  }
}

extension PasswordValidation {
  /// A comprehensive password validator with standard security requirements.
  ///
  /// This validator enforces the following rules:
  /// - Minimum length: 8 characters
  /// - Maximum length: 64 characters
  /// - Must contain at least one uppercase letter
  /// - Must contain at least one lowercase letter
  /// - Must contain at least one digit
  /// - Must contain at least one special character
  ///
  /// ## Example
  /// ```swift
  /// let validator = PasswordValidation.default
  /// try validator.validate("MySecurePass123!") // Returns true
  /// ```
  public static var `default`: Self {
    .init { password in
      let minLength: Int = 8
      let maxLength: Int = 64

      // Regular expression patterns
      let uppercasePattern: String = ".*[A-Z]+.*"
      let lowercasePattern: String = ".*[a-z]+.*"
      let digitPattern: String = ".*[0-9]+.*"
      let specialCharacterPattern: String = ".*[!&^%$#@()/]+.*"

      // Check password length
      if password.count < minLength {
        throw PasswordValidation.Error.tooShort(minLength: minLength)
      }
      if password.count > maxLength {
        throw PasswordValidation.Error.tooLong(maxLength: maxLength)
      }

      // Check for uppercase, lowercase, digit, and special character
      if !matches(pattern: uppercasePattern, in: password) {
        throw PasswordValidation.Error.missingUppercase
      }
      if !matches(pattern: lowercasePattern, in: password) {
        throw PasswordValidation.Error.missingLowercase
      }
      if !matches(pattern: digitPattern, in: password) {
        throw PasswordValidation.Error.missingDigit
      }
      if !matches(pattern: specialCharacterPattern, in: password) {
        throw PasswordValidation.Error.missingSpecialCharacter
      }

      return true
    }
  }

  /// A basic password validator with minimal requirements.
  ///
  /// This validator only checks for a minimum length of 4 characters,
  /// making it suitable for testing or applications with relaxed security requirements.
  ///
  /// ## Example
  /// ```swift
  /// let validator = PasswordValidation.simple
  /// try validator.validate("test") // Returns true
  /// ```
  public static var simple: Self {
    .init { password in
      guard password.count >= 4 else {
        throw PasswordValidation.Error.tooShort(minLength: 4)
      }
      return true
    }
  }
}

private func matches(pattern: String, in text: String) -> Bool {
  guard let regex = try? Regex(pattern) else { return false }
  return text.contains(regex)
}

extension PasswordValidation {
  /// Errors that can occur during password validation.
  public enum Error: Swift.Error, Equatable, CustomStringConvertible {
    /// The password is shorter than the required minimum length.
    case tooShort(minLength: Int)
    /// The password exceeds the maximum allowed length.
    case tooLong(maxLength: Int)
    /// The password does not contain any uppercase letters.
    case missingUppercase
    /// The password does not contain any lowercase letters.
    case missingLowercase
    /// The password does not contain any digits.
    case missingDigit
    /// The password does not contain any special characters.
    case missingSpecialCharacter
  }
}

extension PasswordValidation.Error {
  /// A localized description of the validation error.
  public var description: String {
    switch self {
    case .tooShort(let minLength):
      return TranslatedString(
        dutch: "Wachtwoord moet minstens \(minLength) tekens lang zijn.",
        english: "Password must be at least \(minLength) characters long."
      ).description
    case .tooLong(let maxLength):
      return TranslatedString(
        dutch: "Wachtwoord mag maximaal \(maxLength) tekens lang zijn.",
        english: "Password must be no more than \(maxLength) characters long."
      ).description
    case .missingUppercase:
      return TranslatedString(
        dutch: "Wachtwoord moet minstens één hoofdletter bevatten.",
        english: "Password must contain at least one uppercase letter."
      ).description
    case .missingLowercase:
      return TranslatedString(
        dutch: "Wachtwoord moet minstens één kleine letter bevatten.",
        english: "Password must contain at least one lowercase letter."
      ).description
    case .missingDigit:
      return TranslatedString(
        dutch: "Wachtwoord moet minstens één cijfer bevatten.",
        english: "Password must contain at least one digit."
      ).description
    case .missingSpecialCharacter:
      return TranslatedString(
        dutch: "Wachtwoord moet minstens één speciaal teken bevatten (bijv. !&^%$#@()/).",
        english: "Password must contain at least one special character (e.g., !&^%$#@()/)."
      ).description
    }
  }
}
