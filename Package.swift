// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "UsersLocalizations",
	platforms: [
		.iOS(.v18),
		.macOS(.v15),
		.tvOS(.v16),
		.watchOS(.v8),
	],
    products: [
        .library(
			name: "Lingo",
			targets: [
				"Lingo"
			]
		)
    ],
	dependencies: [
		//.package(url: "https://github.com/kommthom/swift-parsing", from: "1.0.0"),
		.package(name: "swift-parsing", path: "../swift-parsing"),
		//.package(url: "https://github.com/kommthom/UserDTOs", from: "0.1.0"),
		.package(name: "UserDTOs", path: "../UserDTOs"),
		.package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0")
	],
    targets: [
        .target(
			name: "Lingo",
			dependencies: [
				.product(
					name: "Parsing",
					package: "swift-parsing"
				),
				.product(
					name: "UserDTOs",
					package: "UserDTOs"
				),
				.product(
					name: "Tagged",
					package: "swift-tagged"
				)
			]
		),
        .testTarget(
			name: "LingoTests",
			dependencies: [
				"Lingo"
			]
		)
    ]
)
