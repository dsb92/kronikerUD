import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Load enviroment if any
    Environment.dotenv()
    
    try app.databases.use(.postgres(url: Environment.databaseURL), as: .psql)
    
    // Tables
    app.migrations.add(CreateSubject())
    app.migrations.add(CreateDetail())
    
    // Fields
    app.migrations.add(SubjectAddBackgroundColor(), to: .psql)

    // register routes
    try routes(app)
}
