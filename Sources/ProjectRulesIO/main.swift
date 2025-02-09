// Sources/ProjectRulesIO/main.swift
import Vapor
import ProjectRulesGenerator

func routes(_ app: Application) throws {

    // ルート：HTML フォームを表示
    app.get { req -> Response in
        let html = """
        <!DOCTYPE html>
        <html lang="ja">
        <head>
            <meta charset="UTF-8">
            <title>Project Rules (.mdc) Generator</title>
            <style>
                body { font-family: sans-serif; margin: 40px; }
                .keyword-list { margin-top: 20px; }
                .keyword-item {
                    display: inline-block;
                    background-color: #ddd;
                    padding: 5px 10px;
                    margin: 5px;
                    border-radius: 5px;
                }
            </style>
        </head>
        <body>
            <h1>Project Rules (.mdc) Generator</h1>
            <input type="text" id="keywordInput" placeholder="プログラミング言語、IDE等を入力" list="suggestions">
            <datalist id="suggestions">
                <option value="Swift"></option>
                <option value="Objective-C"></option>
                <option value="Python"></option>
                <option value="JavaScript"></option>
                <option value="Xcode"></option>
                <option value="Visual Studio"></option>
                <option value="IntelliJ"></option>
                <option value="Eclipse"></option>
            </datalist>
            <button id="addKeyword">Add Keyword</button>
            <div class="keyword-list" id="keywordList"></div>
            <br>
            <button id="submitBtn">Submit</button>
            
            <script>
                const keywordInput = document.getElementById('keywordInput');
                const addKeywordBtn = document.getElementById('addKeyword');
                const keywordListDiv = document.getElementById('keywordList');
                let keywords = [];
                
                addKeywordBtn.addEventListener('click', () => {
                    const value = keywordInput.value.trim();
                    if (value && !keywords.includes(value)) {
                        keywords.push(value);
                        const span = document.createElement('span');
                        span.textContent = value;
                        span.className = 'keyword-item';
                        keywordListDiv.appendChild(span);
                        keywordInput.value = '';
                    }
                });
                
                document.getElementById('submitBtn').addEventListener('click', () => {
                    if(keywords.length === 0) {
                        alert("少なくとも 1 つのキーワードを追加してください。");
                        return;
                    }
                    const url = '/projectrules/api/' + encodeURIComponent(keywords.join(','));
                    window.location.href = url;
                });
            </script>
        </body>
        </html>
        """
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/html; charset=utf-8")
        return Response(status: .ok, headers: headers, body: .init(string: html))
    }

    // API エンドポイント：URL パラメータからキーワードを取得し、.mdc ファイル内容を結合して表示
    app.get("projectrules", "api", ":keywords") { req async throws -> Response in
        guard let keywordsParam = req.parameters.get("keywords") else {
            throw Abort(.badRequest)
        }
        let decoded = keywordsParam.removingPercentEncoding ?? keywordsParam
        let keywords = decoded.split(separator: ",").map { String($0) }
        let content = try await ProjectRulesGenerator.generate(for: keywords)

        let html = """
        <!DOCTYPE html>
        <html lang="ja">
        <head>
            <meta charset="UTF-8">
            <title>Generated .mdc Content</title>
            <style>
                body { font-family: monospace; white-space: pre; margin: 40px; }
            </style>
        </head>
        <body>
        \(content)
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
    try routes(app)
    return app
}

do {
    try app(.development).run()
} catch {
    print("Failed to start application: \(error)")
}
