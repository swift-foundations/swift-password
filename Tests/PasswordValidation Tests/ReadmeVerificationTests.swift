//
//  ReadmeVerificationTests.swift
//  swift-password-validation
//
//  Created for README verification
//

import Dependencies
import Testing

@testable import PasswordValidation

@Suite(
  "README Verification",
  .dependency(\.locale, .english)
)
struct ReadmeVerificationTests {

  @Test("Example from README line 47-59: Basic Usage")
  func exampleBasicUsage() throws {
    // Use the comprehensive validator
    let validator: PasswordValidation = PasswordValidation.default

    do {
      let isValid: Bool = try validator.validate("MySecurePass123!")
      #expect(isValid == true)
    } catch let error as PasswordValidation.Error {
      Issue.record("Validation failed: \(error.description)")
    }
  }

  @Test("Example from README line 63-74: With Dependencies")
  func exampleWithDependencies() throws {
    struct LoginService {
      @Dependency(\.passwordValidation) var passwordValidation: PasswordValidation

      func validateUserPassword(_ password: String) throws -> Bool {
        return try passwordValidation.validate(password)
      }
    }

    let service: LoginService = withDependencies {
      $0.passwordValidation = .default
    } operation: {
      LoginService()
    }

    let result: Bool = try service.validateUserPassword("MySecurePass123!")
    #expect(result == true)
  }

  @Test("Example from README line 88-91: Default Validator")
  func exampleDefaultValidator() throws {
    let validator: PasswordValidation = PasswordValidation.default
    let result: Bool = try validator.validate("MySecurePass123!")
    #expect(result == true)
  }

  @Test("Example from README line 97-100: Simple Validator")
  func exampleSimpleValidator() throws {
    let validator: PasswordValidation = PasswordValidation.simple
    let result: Bool = try validator.validate("test")
    #expect(result == true)
  }

  @Test("Example from README line 106-118: Custom Validation")
  func exampleCustomValidation() throws {
    let customValidator: PasswordValidation = PasswordValidation { password in
      guard password.count >= 6 else {
        throw PasswordValidation.Error.tooShort(minLength: 6)
      }

      guard !password.lowercased().contains("password") else {
        throw PasswordValidation.Error.missingSpecialCharacter
      }

      return true
    }

    // Test valid password
    let result: Bool = try customValidator.validate("MySecret123!")
    #expect(result == true)

    // Test invalid password (contains "password")
    #expect(throws: PasswordValidation.Error.missingSpecialCharacter) {
      try customValidator.validate("mypassword123")
    }

    // Test too short
    #expect(throws: PasswordValidation.Error.tooShort(minLength: 6)) {
      try customValidator.validate("Pass1")
    }
  }

  @Test("Example from README line 124-136: Error Handling")
  func exampleErrorHandling() throws {
    var caughtCorrectError: Bool = false

    do {
      try PasswordValidation.default.validate("weak")
    } catch PasswordValidation.Error.tooShort(let minLength) {
      caughtCorrectError = true
      #expect(minLength == 8)
    } catch PasswordValidation.Error.missingUppercase {
      // This is also acceptable since "weak" has multiple issues
      caughtCorrectError = true
    } catch PasswordValidation.Error.missingDigit {
      // This is also acceptable since "weak" has multiple issues
      caughtCorrectError = true
    } catch {
      Issue.record("Unexpected error: \(error)")
    }

    #expect(caughtCorrectError)
  }

  @Suite("Verify all error cases from README line 140-146")
  struct ErrorCasesVerification {

    @Test("tooShort error")
    func tooShortError() {
      let error: PasswordValidation.Error = PasswordValidation.Error.tooShort(minLength: 8)
      #expect(error.description.contains("at least 8 characters"))
    }

    @Test("tooLong error")
    func tooLongError() {
      let error: PasswordValidation.Error = PasswordValidation.Error.tooLong(maxLength: 64)
      #expect(error.description.contains("no more than 64 characters"))
    }

    @Test("missingUppercase error")
    func missingUppercaseError() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingUppercase
      #expect(error.description.contains("uppercase"))
    }

    @Test("missingLowercase error")
    func missingLowercaseError() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingLowercase
      #expect(error.description.contains("lowercase"))
    }

    @Test("missingDigit error")
    func missingDigitError() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingDigit
      #expect(error.description.contains("digit"))
    }

    @Test("missingSpecialCharacter error")
    func missingSpecialCharacterError() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingSpecialCharacter
      #expect(error.description.contains("special character"))
    }
  }

  @Suite("Verify default validator requirements from README line 80-86")
  struct DefaultValidatorRequirements {

    @Test("Requires 8-64 characters")
    func lengthRequirement() {
      let validator: PasswordValidation = PasswordValidation.default

      // Too short
      #expect(throws: PasswordValidation.Error.tooShort(minLength: 8)) {
        try validator.validate("Pass1!")
      }

      // Too long (65 characters)
      #expect(throws: PasswordValidation.Error.tooLong(maxLength: 64)) {
        try validator.validate(String(repeating: "Aa1!", count: 17))
      }

      // Valid length
      let result: Bool? = try? validator.validate("Pass123!")
      #expect(result == true)
    }

    @Test("Requires uppercase letter")
    func uppercaseRequirement() {
      let validator: PasswordValidation = PasswordValidation.default

      #expect(throws: PasswordValidation.Error.missingUppercase) {
        try validator.validate("password123!")
      }
    }

    @Test("Requires lowercase letter")
    func lowercaseRequirement() {
      let validator: PasswordValidation = PasswordValidation.default

      #expect(throws: PasswordValidation.Error.missingLowercase) {
        try validator.validate("PASSWORD123!")
      }
    }

    @Test("Requires digit")
    func digitRequirement() {
      let validator: PasswordValidation = PasswordValidation.default

      #expect(throws: PasswordValidation.Error.missingDigit) {
        try validator.validate("Password!")
      }
    }

    @Test("Requires special character")
    func specialCharacterRequirement() {
      let validator: PasswordValidation = PasswordValidation.default

      #expect(throws: PasswordValidation.Error.missingSpecialCharacter) {
        try validator.validate("Password123")
      }
    }
  }
}
