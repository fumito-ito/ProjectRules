import XCTest
import ArgumentParser
@testable import ProjectRulesCLI
@testable import ProjectRulesGenerator

final class ProjectRulesCLITests: XCTestCase {
    
    func testCommandConfiguration() {
        XCTAssertEqual(ProjectRulesCLI.configuration.commandName, "ProjectRules")
        XCTAssertTrue(ProjectRulesCLI.configuration.abstract.contains("Generate .mdc files"))
    }
    
    func testArgumentParsing() throws {
        // Test basic argument parsing
        let parsedCommand = try ProjectRulesCLI.parse([
            "keyword1,keyword2",
            "--repo", "test-owner/test-repo",
            "--target-directory", "/tmp",
            "--dry-run"
        ])
        
        XCTAssertEqual(parsedCommand.keywords, "keyword1,keyword2")
        XCTAssertEqual(parsedCommand.repo, "test-owner/test-repo")
        XCTAssertEqual(parsedCommand.targetDirectory, "/tmp")
        XCTAssertTrue(parsedCommand.dryRun)
    }
    
    func testOptionalArgumentDefaults() throws {
        // Test default values when optional arguments are not provided
        let parsedCommand = try ProjectRulesCLI.parse([
            "keyword1"
        ])
        
        XCTAssertEqual(parsedCommand.keywords, "keyword1")
        XCTAssertNil(parsedCommand.repo)
        XCTAssertNil(parsedCommand.targetDirectory)
        XCTAssertFalse(parsedCommand.dryRun)
    }
    
    func testKeywordSplitting() throws {
        // This test verifies the keyword splitting logic
        let command = try ProjectRulesCLI.parse(["keyword1,keyword2, keyword3"])
        
        // We can't directly test the private run method, but we can test the logic
        // that would be used to split the keywords
        let keywordsArray = command.keywords.split(separator: ",").map { 
            String($0.trimmingCharacters(in: .whitespaces)) 
        }
        
        XCTAssertEqual(keywordsArray.count, 3)
        XCTAssertEqual(keywordsArray[0], "keyword1")
        XCTAssertEqual(keywordsArray[1], "keyword2")
        XCTAssertEqual(keywordsArray[2], "keyword3")
    }
}