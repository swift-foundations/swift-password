// swift-tools-version:5.10

import PackageDescription

extension String {
    static let passwordValidation: Self = "PasswordValidation"
}

extension Target.Dependency {
    static var passwordValidation: Self { .target(name: .passwordValidation) }
}

extension Target.Dependency {
    static var translating: Self { .product(name: "Translating", package: "swift-translating") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "Dependencies Test Support", package: "swift-dependencies") }
}

let package = Package(
    name: "swift-password-validation",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: .passwordValidation, targets: [.passwordValidation]),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-translating", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-dependencies.git", branch: "main")
    ],
    targets: [
        .target(
            name: .passwordValidation,
            dependencies: [
                .translating,
                .dependencies
            ]
        ),
        .testTarget(
            name: .passwordValidation.tests,
            dependencies: [
                .passwordValidation,
                .dependenciesTestSupport
            ]
        ),
    ]
)

extension String { var tests: Self { self + " Tests" } }
