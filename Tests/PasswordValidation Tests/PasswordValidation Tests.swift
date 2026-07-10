//
//  PasswordValidation Tests.swift
//  coenttb-server
//
//  Created by Coen ten Thije Boonkkamp on 23/07/2025.
//

import Dependencies
import Dependencies_Test_Support
import Testing

@testable import PasswordValidation

@Suite(
  .dependency(\.language, .english),
  .dependency(\.passwordValidation, .default)
)
struct `PasswordValidation Tests` {

  @Suite
  struct `Valid Passwords` {

    @Test
    func `Valid password with all requirements`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let validPassword: String = "Password123!"
      #expect(try isValidPassword(validPassword) == true)
    }

    @Test
    func `Valid password with minimum length`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let validPassword: String = "Pass123!"
      #expect(try isValidPassword(validPassword) == true)
    }

    @Test
    func `Valid password with multiple special characters`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let validPassword: String = "Password123!@#$%^&*()"
      #expect(try isValidPassword(validPassword) == true)
    }

    @Test
    func `Valid password with maximum allowed length`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let validPassword: String = String(repeating: "Aa1!", count: 16)  // 64 characters
      #expect(try isValidPassword(validPassword) == true)
    }
  }

  @Suite
  struct `Invalid Passwords - Length` {

    @Test
    func `Password too short throws tooShort error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let shortPassword: String = "Pass1!"

      #expect(throws: PasswordValidation.Error.tooShort(minLength: 8)) {
        try isValidPassword(shortPassword)
      }
    }

    @Test
    func `Password too long throws tooLong error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let longPassword: String = String(repeating: "Aa1!", count: 17)  // 68 characters
      #expect(throws: PasswordValidation.Error.tooLong(maxLength: 64)) {
        try isValidPassword(longPassword)
      }
    }
  }

  @Suite
  struct `Invalid Passwords - Missing Character Types` {

    @Test
    func `Password missing uppercase throws missingUppercase error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let password: String = "password123!"
      #expect(throws: PasswordValidation.Error.missingUppercase) {
        try isValidPassword(password)
      }
    }

    @Test
    func `Password missing lowercase throws missingLowercase error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let password: String = "PASSWORD123!"

      #expect(throws: PasswordValidation.Error.missingLowercase) {
        try isValidPassword(password)
      }
    }

    @Test
    func `Password missing digit throws missingDigit error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let password: String = "Password!"

      #expect(throws: PasswordValidation.Error.missingDigit) {
        try isValidPassword(password)
      }
    }

    @Test
    func `Password missing special character throws missingSpecialCharacter error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let password: String = "Password123"

      #expect(throws: PasswordValidation.Error.missingSpecialCharacter) {
        try isValidPassword(password)
      }
    }
  }

  @Suite
  struct `PasswordValidation.Error Tests` {

    @Test
    func `TooShort error has correct description`() {
      let error: PasswordValidation.Error = PasswordValidation.Error.tooShort(minLength: 8)
      #expect(error.description.contains("at least 8 characters"))
    }

    @Test
    func `TooLong error has correct description`() {
      let error: PasswordValidation.Error = PasswordValidation.Error.tooLong(maxLength: 64)
      #expect(error.description.contains("no more than 64 characters"))
    }

    @Test
    func `MissingUppercase error has correct description`() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingUppercase
      #expect(error.description.contains("uppercase letter"))
    }

    @Test
    func `MissingLowercase error has correct description`() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingLowercase
      #expect(error.description.contains("lowercase letter"))
    }

    @Test
    func `MissingDigit error has correct description`() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingDigit
      #expect(error.description.contains("digit"))
    }

    @Test
    func `MissingSpecialCharacter error has correct description`() {
      let error: PasswordValidation.Error = PasswordValidation.Error.missingSpecialCharacter
      #expect(error.description.contains("special character"))
    }
  }

  @Suite
  struct `Edge Cases` {

    @Test
    func `Empty password throws tooShort error`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let emptyPassword: String = ""

      #expect(throws: PasswordValidation.Error.tooShort(minLength: 8)) {
        try isValidPassword(emptyPassword)
      }
    }

    @Test
    func `Password with Unicode characters`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let unicodePassword: String = "Pássword123!"
      #expect(try isValidPassword(unicodePassword) == true)
    }

    @Test
    func `Password with all allowed special characters`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let password: String = "Password123!&^%$#@()/"
      #expect(try isValidPassword(password) == true)
    }

    @Test
    func `Password with spaces`() async throws {
      @Dependency(\.passwordValidation.validate) var isValidPassword:
        @Sendable (String) throws -> Bool
      let password: String = "Pass word123!"
      #expect(try isValidPassword(password) == true)
    }
  }
}
