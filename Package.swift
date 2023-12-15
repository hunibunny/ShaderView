// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "ShaderView",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ShaderView",
            targets: ["ShaderView"]),
    ],
    targets: [  
        .target(
            name: "ShaderView",
            dependencies: []),
        .testTarget(
            name: "ShaderViewTests",
            dependencies: ["ShaderView"]),
    ]
)
