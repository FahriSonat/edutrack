// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .macOS("12.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "cloud_firestore", path: "../.packages/cloud_firestore-7.1.0"),
        .package(name: "file_picker_darwin", path: "../.packages/file_picker_darwin-2.5.1"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-7.0.1"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-5.1.0"),
        .package(name: "url_launcher_macos", path: "../.packages/url_launcher_macos-3.2.6"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "cloud-firestore", package: "cloud_firestore"),
                .product(name: "file-picker-darwin", package: "file_picker_darwin"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "url-launcher-macos", package: "url_launcher_macos"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
