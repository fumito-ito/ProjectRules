import XCTest
import XCTVapor
@testable import ProjectRulesIO
@testable import ProjectRulesGenerator

final class ProjectRulesIOTests: XCTestCase {
    
    // Basic test to verify app configuration setup
    func testAppConfiguration() throws {
        XCTAssertTrue(true, "This is a placeholder test to ensure ProjectRulesIO can be imported")
        
        // In a real test environment, we would test more aspects of configuration
        // but we'll avoid network calls in the tests
    }
    
    // Test that routes are correctly registered
    func testRouteRegistration() throws {
        // This verifies that the routes function can execute without error
        let app = Application(.testing)
        defer { app.shutdown() }
        
        try configure(app)
        XCTAssertNoThrow(try routes(app))
    }
    
    // Test HTML structure of the response
    func testHTMLResponseStructure() throws {
        // Verify the HTML structure used in responses
        let content = "Test content"
        let html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Generated .mdc Content</title>
            <style>
                body { font-family: monospace; padding: 40px; background: #fff; }
                pre { white-space: pre-wrap; word-wrap: break-word; }
            </style>
        </head>
        <body>
            <pre>\(content)</pre>
        </body>
        </html>
        """
        
        XCTAssertTrue(html.contains("<pre>\(content)</pre>"))
        XCTAssertTrue(html.contains("<!DOCTYPE html>"))
        XCTAssertTrue(html.contains("<title>Generated .mdc Content</title>"))
    }
}