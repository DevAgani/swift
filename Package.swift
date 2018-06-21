// swift-tools-version:4.2

import PackageDescription
import Foundation

extension String {
	var PascalCased: String {
		let items = self.components(separatedBy: "-")
		return items.reduce("", { $0 + $1.capitalized })
	}
}

let path = FileManager.default.currentDirectoryPath + "/config.json"
var allProblems = [String]()

if
    let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe),
    let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
    let jsonDict = json as? [String: Any],
    let exercisesDict = jsonDict["exercises"] as? [[String: Any]],
    let exercises = exercisesDict.map({ $0["slug"] }) as? [String]
{
    allProblems += exercises
} else {
    print("Could not parse config.json at \(path)")
}
let allProblemsCamelCase = allProblems.map{ $0.PascalCased}

let packageDependencies:[Package.Dependency] = allProblems.map { .package(path: "./exercises/\($0)/") }
let targetDependencies:[Target.Dependency] = allProblemsCamelCase.map { .byNameItem(name:"\($0)") }

let sources  = allProblems.map { "./\($0)/Sources" }
let testSources  = allProblems.map { "./\($0)/Tests" }

let package = Package(
    name: "xswift",
    products: [
        .library(
            name: "xswift",
            targets: ["xswift"]),
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "xswift",
            dependencies: targetDependencies, 
            path: "./exercises", 
            sources: sources
            ),
        .testTarget(
            name: "xswiftTests",
            dependencies: ["xswift"], 
            path: "./exercises", 
            sources: testSources
            ),
        ]
    )