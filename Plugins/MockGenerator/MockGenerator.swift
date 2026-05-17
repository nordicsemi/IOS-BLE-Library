import Foundation
import PackagePlugin

@main
struct MockGenerator: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let tool = try context.tool(named: "MockGeneratorTool")
        let sourceRoot = context.package.directory.appending("Sources", "iOS-BLE-Library")
        let outputRoot = context.pluginWorkDirectory

        let inputs = try enumerateSwiftFiles(under: sourceRoot)

        return inputs.map { input in
            let relative = String(input.string.dropFirst(sourceRoot.string.count + 1))
            let output = outputRoot.appending(relative)
            return .buildCommand(
                displayName: "MockCopy \(relative)",
                executable: tool.path,
                arguments: [input.string, output.string],
                inputFiles: [input],
                outputFiles: [output]
            )
        }
    }
}

private func enumerateSwiftFiles(under directory: Path) throws -> [Path] {
    guard let enumerator = FileManager.default.enumerator(atPath: directory.string) else {
        return []
    }
    var results: [Path] = []
    for case let relativePath as String in enumerator where relativePath.hasSuffix(".swift") {
        results.append(directory.appending(relativePath))
    }
    return results
}
