// Sources/ProjectRulesCLI/main.swift
import Foundation
import ArgumentParser
import ProjectRulesGenerator

@main
struct ProjectRulesCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ProjectRules",
        abstract: "Generate .mdc files based on provided keywords."
    )

    @Argument(help: "Comma-separated keywords (e.g., best-practices-for-writitng-nextjs)")
    var keywords: String

    @Option(name: [.short, .long], help: "Specify a GitHub repository in owner/reponame format. If provided, the {keyword}.mdc file from that repository will be used.")
    var repo: String?

    @Option(name: [.short, .long], help: "Specify the output directory. Defaults to the current directory.")
    var targetDirectory: String?

    @Flag(help: "If set, display the output content to standard output instead of writing to a file.")
    var dryRun: Bool = false

    mutating func run() async throws {
        let keywordsArray = keywords.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }

        for keyword in keywordsArray {
            do {
                let content = try await ProjectRulesGenerator.fetch(for: keyword, repository: repo)
                if dryRun {
                    print("===== \(keyword).mdc =====")
                    print(content)
                } else {
                    let outputDir: URL
                    if let targetDirectory = targetDirectory, !targetDirectory.isEmpty {
                        outputDir = URL(fileURLWithPath: targetDirectory, isDirectory: true)
                    } else {
                        outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
                    }
                    let fileURL = outputDir.appendingPathComponent("\(keyword).mdc")
                    try content.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("Created file: \(fileURL.path)")
                }
            } catch {
                print("Error processing keyword '\(keyword)': \(error.localizedDescription)")
            }
        }
    }
}
