// Sources/ProjectRulesGenerator/ProjectRulesGenerator.swift
import Foundation

/// キーワードに対応するリモートの .mdc ファイルを取得し、その内容を結合または個別に返す処理
public struct ProjectRulesGenerator {

    /// リポジトリ指定がない場合に利用する既定の mdc ファイルリポジトリのベース URL
    public static let defaultBaseURLString = "https://raw.githubusercontent.com/fumito-ito/mdcvalult/main/"

    /// 複数のキーワードに対応する {キーワード}.mdc ファイルを取得し、結合した文字列を返します（Webサービス用）。
    public static func generate(for keywords: [String], repository: String? = nil) async throws -> String {
        var combinedContent = ""
        for keyword in keywords {
            let content = try await fetch(for: keyword, repository: repository)
            if keywords.count > 1 {
                combinedContent += "## \(keyword).mdc\n\n"
            }
            combinedContent += content
            combinedContent += "\n\n"
        }
        return combinedContent
    }

    /// 単一のキーワードに対応する {キーワード}.mdc ファイルの内容を取得して返します（CLI 用）。
    public static func fetch(for keyword: String, repository: String? = nil) async throws -> String {
        let baseURL: String
        if let repo = repository, !repo.isEmpty {
            baseURL = "https://raw.githubusercontent.com/\(repo)/main/"
        } else {
            baseURL = defaultBaseURLString
        }
        let fileExtension = ".mdc"
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw ProjectRulesError.invalidKeywordEncoding(keyword: keyword)
        }
        let fileName = "\(encodedKeyword)\(fileExtension)"
        let urlString = baseURL + fileName
        guard let url = URL(string: urlString) else {
            throw ProjectRulesError.invalidURL(urlString: urlString)
        }

        var request = URLRequest(url: url)

        // 既存の環境変数からGITHUB_TOKENを取得（ユーザー操作不要で自動利用）
        if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"], !token.isEmpty {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw ProjectRulesError.fetchFailed(keyword: keyword, urlString: urlString, statusCode: httpResponse.statusCode)
        }
        guard let fileContent = String(data: data, encoding: .utf8) else {
            throw ProjectRulesError.decodingFailed(keyword: keyword)
        }
        return fileContent
    }
}
