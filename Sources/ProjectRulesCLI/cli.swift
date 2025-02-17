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

    @Argument(help: "カンマ区切りのキーワード（例: Swift,Xcode,Python）")
    var keywords: String

    @Option(name: [.short, .long], help: "GitHub リポジトリを owner/reponame 形式で指定します。指定された場合、そのリポジトリ内の {キーワード}.mdc ファイルを参照します")
    var repo: String?

    @Option(name: [.short, .long], help: "出力先のディレクトリを指定します。省略時はカレントディレクトリ")
    var targetDirectory: String?

    @Flag(help: "指定した場合、ファイル出力せず内容を標準出力に表示します")
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
