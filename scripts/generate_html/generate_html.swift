//
//  generate_html.swift
//  ProjectRulesGenerator
//
//  Created by 伊藤史 on 2025/02/24.
//

import Foundation

struct MDCFile: Codable {
    let mdc: [String]
}

guard CommandLine.arguments.count > 1 else {
    print("Usage: swift scripts/hoge.swift <outputFile>")
    exit(1)
}

let outputFilePath = CommandLine.arguments[1]

// Determine the directory where this script resides.
let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent()

// Paths for mdc.json and index.html.template relative to the script directory.
let mdcPath = scriptDir.appendingPathComponent("mdc.json")
let templatePath = scriptDir.appendingPathComponent("index.html.template")

do {
    // Read and decode mdc.json
    let mdcData = try Data(contentsOf: mdcPath)
    let mdcFile = try JSONDecoder().decode(MDCFile.self, from: mdcData)

    // Encode the suggestions array as a JSON string.
    let suggestionsJSONData = try JSONEncoder().encode(mdcFile.mdc)
    guard let suggestionsJSONString = String(data: suggestionsJSONData, encoding: .utf8) else {
        print("Failed to encode suggestions array to string.")
        exit(1)
    }

    // Read the template file.
    let templateContent = try String(contentsOf: templatePath, encoding: .utf8)
    let renderedContent = templateContent.replacingOccurrences(of: "{{suggestions}}", with: suggestionsJSONString)

    // Convert the output file path to an absolute URL relative to the current working directory.
    let cwd = FileManager.default.currentDirectoryPath
    let outputFileURL = URL(fileURLWithPath: outputFilePath, relativeTo: URL(fileURLWithPath: cwd)).standardizedFileURL

    // Write the rendered content.
    try renderedContent.write(to: outputFileURL, atomically: true, encoding: .utf8)

    print("Successfully updated \(outputFileURL.path)")
} catch {
    print("Error: \(error)")
    exit(1)
}
