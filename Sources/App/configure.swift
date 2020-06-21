import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Load enviroment if any
    Environment.dotenv()
    
    var config = PostgresConfiguration(url: Environment.get("DATABASE_URL")!)!
    config.tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
    app.databases.use(.postgres(configuration: config), as: .psql)

    app.migrations.add(CreateSubject())
    app.migrations.add(CreateDetail())

    // register routes
    try routes(app)
}
