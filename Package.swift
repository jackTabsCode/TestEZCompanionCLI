// swift-tools-version:5.7
import PackageDescription

let package = Package(
	name: "TestEZCompanionCLI",
	platforms: [
		.macOS(.v12),
	],
	products: [
		.executable(
			name: "TestEZCompanionCLI",
			targets: ["TestEZCompanionCLI"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
		.package(url: "https://github.com/vapor/vapor", from: "4.63.0"),
		.package(url: "https://github.com/dduan/TOMLDecoder", from: "0.1.2"),
		.package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.7"),
	],
	targets: [
		.executableTarget(
			name: "TestEZCompanionCLI",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Vapor", package: "vapor"),
				"TOMLDecoder",
				"AnyCodable",
			],
			path: "Sources"
		),
	]
)
