import Fluent
import FluentPostgresDriver
import Vapor
import FCM

// configures your application
public func configure(_ app: Application) throws {
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Load enviroment if any
    Environment.dotenv()
    
    // Heroku uses SSL verifcation when connecting to database.
    // Below is therefor only necessary if you want to debug production database
//    var config = PostgresConfiguration(url: Environment.databaseURL)!
//    config.tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
//    app.databases.use(.postgres(configuration: config), as: .psql)
    try app.databases.use(.postgres(url: Environment.databaseURL), as: .psql)
    
    // Tables
    app.migrations.add(CreateSubject())
    app.migrations.add(CreateDetail())
    app.migrations.add(CreatePost())
    app.migrations.add(CreateComment())
    app.migrations.add(CreateAllowedDevice())
    app.migrations.add(CreatePushToken())
    app.migrations.add(CreatePushDevice())
    app.migrations.add(CreateNotificationEvent())
    app.migrations.add(CreateNotification())
    app.migrations.add(CreateChannel())
    app.migrations.add(CreatePostFilter())
    
    // Fields
    //TODO: Migrations below can be removed when ready for production by moving all new fields to table creation migration above.
    app.migrations.add(PushDeviceAddBadgeCount())

    // Middleware
    app.middleware.use(SecretMiddleware(username: Environment.get("BASIC_AUTH_USER") ?? "", password: Environment.get("BASIC_AUTH_PASS") ?? ""))
    app.middleware.use(VersionMiddleware())
    
    // Register routes
    try routes(app)
    
    // Configure FCM
    let directory = DirectoryConfiguration.detect()
    guard let fcmServiceAccountEncoded = Environment.get("FIREBASE_SERVICE_ACCOUNT_BASE64") else { throw Abort(.internalServerError, reason: "Missing Firebase service account setup") }
    
    if let decodedData = Data(base64Encoded: fcmServiceAccountEncoded), let decodedString = String(data: decodedData, encoding: .utf8) {
        // Create tmp dir
        let dir = directory.workingDirectory + "tmp"
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
        
        // Create tmp file
        let path = dir + "/chronichelper-firebase-adminsdk-ftsrk-f1b395cbdc.json"
        if !FileManager.default.fileExists(atPath:path){
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        try decodedString.write(toFile: path, atomically: true, encoding: .utf8)
        app.fcm.configuration = FCMConfiguration(pathToServiceAccountKey: path)
    }
}
