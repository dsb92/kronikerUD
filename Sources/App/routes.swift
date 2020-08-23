import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: SubjectController())
    try app.register(collection: PostController())
    try app.register(collection: AllowedDeviceController())
    try app.register(collection: PushTokenController())
    try app.register(collection: PushDeviceController())
    try app.register(collection: NotificationEventController())
    try app.register(collection: NotificationController())
    try app.register(collection: ChannelController())
}
