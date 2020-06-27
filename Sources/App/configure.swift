import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Load enviroment if any
    Environment.dotenv()
    
    // Heroku uses SSL verifcation when connecting to database.
    // Below is therefor only necessary if you want to debug production database
    var config = PostgresConfiguration(url: Environment.databaseURL)!
    config.tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
    app.databases.use(.postgres(configuration: config), as: .psql)
    
    // Tables
    app.migrations.add(CreateSubject())
    app.migrations.add(CreateDetail())
    
    // Fields
    app.migrations.add(SubjectAddBackgroundColor())

    // register routes
    try routes(app)
}
