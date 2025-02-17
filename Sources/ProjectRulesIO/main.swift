// Sources/ProjectRulesIO/main.swift
import Vapor
import ProjectRulesGenerator

func routes(_ app: Application) throws {
    // index.html を読み込んでサーバー側で候補配列を埋め込むルート
    app.get { req -> Response in
        // mdc.json のパス（プロジェクト直下に配置している前提）
        let mdcPath = req.application.directory.workingDirectory + "mdc.json"
        let mdcData = try Data(contentsOf: URL(fileURLWithPath: mdcPath))
        let mdcFile = try JSONDecoder().decode(MDCFile.self, from: mdcData)

        // 候補配列を JSON 文字列にエンコード
        let suggestionsJSONData = try JSONEncoder().encode(mdcFile.mdc)
        let suggestionsJSON = String(data: suggestionsJSONData, encoding: .utf8) ?? "[]"

        // Public/index.html ファイルを読み込む
        let filePath = req.application.directory.publicDirectory + "index.html"
        let htmlContent = try String(contentsOfFile: filePath)
        // プレースホルダー {{suggestions}} を JSON に置換
        let renderedHTML = htmlContent.replacingOccurrences(of: "{{suggestions}}", with: suggestionsJSON)

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html; charset=utf-8")
        return Response(status: .ok, headers: headers, body: .init(string: renderedHTML))
    }

    // 例えば、API エンドポイントとして、動的に .mdc ファイル内容を生成して返すルート
    app.get("projectrules", "api", ":keywords") { req async throws -> Response in
        guard let keywordsParam = req.parameters.get("keywords") else {
            throw Abort(.badRequest)
        }
        let decoded = keywordsParam.removingPercentEncoding ?? keywordsParam
        let keywords = decoded.split(separator: ",").map { String($0) }
        let content = try await ProjectRulesGenerator.generate(for: keywords)

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
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html; charset=utf-8")
        return Response(status: .ok, headers: headers, body: .init(string: html))
    }
}

public func app(_ environment: Environment) throws -> Application {
    var env = environment
    try LoggingSystem.bootstrap(from: &env)
    let app = Application(env)
    try configure(app)
    try routes(app)
    return app
}

public func configure(_ app: Application) throws {
    // ここでホスト名を "0.0.0.0" に設定する
    app.http.server.configuration.hostname = "0.0.0.0"
    // 静的ファイルを配信するためのミドルウェア（必要なら設定）
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
}

do {
    try app(.development).run()
} catch {
    print("Failed to start application: \(error)")
}
