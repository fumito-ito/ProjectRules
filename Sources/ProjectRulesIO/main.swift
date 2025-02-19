// Sources/ProjectRulesIO/main.swift
import Vapor
import ProjectRulesGenerator

func routes(_ app: Application) throws {
    // MARK: - `/index.html`
    app.get { req -> EventLoopFuture<Response> in
        let indexPath = req.application.directory.publicDirectory + "index.html"
        let response = req.fileio.streamFile(at: indexPath)
        return req.eventLoop.makeSucceededFuture(response)
    }

    // MARK: - `/projectrules/api/{keywords}`
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
    // CloudRun default setting
    app.http.server.configuration.hostname = "0.0.0.0"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
}

do {
    let envValue = Environment.get("ENV") ?? "dev"
    let env: Environment = (envValue.lowercased() == "prod") ? .production : .development
    try app(env).run()
} catch {
    print("Failed to start application: \(error)")
}
