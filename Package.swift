// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "swiftapp",
	dependencies: [
		.Package(
			url: "https://github.com/PromiseKit/Alamofire-/",
			majorVersion: 1
		),
		.Package(
			url: "https://github.com/kylef/Stencil/",
			majorVersion: 0
		),
	]
)
