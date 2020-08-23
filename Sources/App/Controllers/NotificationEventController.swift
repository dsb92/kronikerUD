import Vapor
import Fluent

struct NotificationEventController: RouteCollection, ApiController {
    typealias Model = NotificationEvent
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "notificationEvents")
    }
    
    func readAll(_ req: Request) throws -> EventLoopFuture<Page<NotificationEvent._Output>> {
        NotificationEvent.query(on: req.db).with(\.$pushToken).paginate(for: req).map { $0.map { $0.output } }
    }
}
