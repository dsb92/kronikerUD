import App
import Vapor
import Backtrace

Backtrace.install()
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.autoMigrate().wait()
try app.run()
