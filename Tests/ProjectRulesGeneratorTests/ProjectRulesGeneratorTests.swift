import XCTest
import Foundation
@testable import ProjectRulesGenerator

final class ProjectRulesGeneratorTests: XCTestCase {
    
    func testInvalidKeywordEncodingError() {
        // This test is a placeholder as we can't easily create an invalid encoding scenario
        let error = ProjectRulesError.invalidKeywordEncoding(keyword: "test-keyword")
        XCTAssertEqual(error.errorDescription, "Invalid keyword encoding: test-keyword")
    }
    
    func testInvalidURLError() {
        let error = ProjectRulesError.invalidURL(urlString: "invalid://url")
        XCTAssertEqual(error.errorDescription, "Invalid URL: invalid://url")
    }
    
    func testFetchFailedError() {
        let error = ProjectRulesError.fetchFailed(keyword: "test", urlString: "https://example.com", statusCode: 404)
        XCTAssertEqual(error.errorDescription, "Failed to fetch content for test from https://example.com (status code: 404)")
        
        let errorWithoutStatusCode = ProjectRulesError.fetchFailed(keyword: "test", urlString: "https://example.com", statusCode: nil)
        XCTAssertEqual(errorWithoutStatusCode.errorDescription, "Failed to fetch content for test from https://example.com")
    }
    
    func testDecodingFailedError() {
        let error = ProjectRulesError.decodingFailed(keyword: "test-keyword")
        XCTAssertEqual(error.errorDescription, "Unable to decode content for test-keyword")
    }
    
    func testDefaultBaseURLString() {
        // Verify the default base URL string is set correctly
        XCTAssertEqual(
            ProjectRulesGenerator.defaultBaseURLString,
            "https://raw.githubusercontent.com/fumito-ito/mdcvalult/main/mdc/"
        )
    }
}