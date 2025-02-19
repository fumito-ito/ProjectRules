//
//  ProjectRulesError.swift
//  ProjectRulesGenerator
//
//  Created by 伊藤史 on 2025/02/08.
//

import Foundation

/// A custom error type representing errors that may occur during the generation process of Project Rules.
public enum ProjectRulesError: Error, LocalizedError {
    case invalidKeywordEncoding(keyword: String)
    case invalidURL(urlString: String)
    case fetchFailed(keyword: String, urlString: String, statusCode: Int?)
    case decodingFailed(keyword: String)

    public var errorDescription: String? {
        switch self {
        case .invalidKeywordEncoding(let keyword):
            return "Invalid keyword encoding: \(keyword)"
        case .invalidURL(let urlString):
            return "Invalid URL: \(urlString)"
        case .fetchFailed(let keyword, let urlString, let statusCode):
            if let code = statusCode {
                return "Failed to fetch content for \(keyword) from \(urlString) (status code: \(code))"
            }
            return "Failed to fetch content for \(keyword) from \(urlString)"
        case .decodingFailed(let keyword):
            return "Unable to decode content for \(keyword)"
        }
    }
}
