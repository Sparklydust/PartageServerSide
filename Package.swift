// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "PartageServerSide",
  products: [
    .library(name: "PartageServerSide", targets: ["App"]),
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    
    // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL
    .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
    .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
    .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0-RC3.2"),
    .package(url: "https://github.com/vapor-community/sendgrid-provider.git", from: "3.0.0")
  ],
  
  targets: [
    .target(name: "App", dependencies: ["FluentPostgreSQL",
                                        "Vapor",
                                        "Leaf",
                                        "Authentication",
                                        "S3",
                                        "SendGrid"]),
    
    .target(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: ["App"])
  ]
)
