import Foundation

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write(Data("usage: MockGeneratorTool <input> <output>\n".utf8))
    exit(1)
}

let input = URL(fileURLWithPath: args[1])
let output = URL(fileURLWithPath: args[2])

let fm = FileManager.default
try fm.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
if fm.fileExists(atPath: output.path) {
    try fm.removeItem(at: output)
}
try fm.copyItem(at: input, to: output)
