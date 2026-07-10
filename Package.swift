// swift-tools-version: 6.3.1

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
        .iOS(.v26),
        .macOS(.v26),
        .macCatalyst(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: .passwordValidation, targets: [.passwordValidation]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-translating.git", branch: "main"),
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
