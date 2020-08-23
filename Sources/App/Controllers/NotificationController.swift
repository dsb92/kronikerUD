import Vapor
import Fluent

struct NotificationController: RouteCollection, ApiController {
    typealias Model = Notification
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "notifications")
    }
}
