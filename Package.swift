// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Grocio",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Grocio",
            targets: ["Grocio"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "Grocio",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
            ]
        ),
    ]
) 