import Fluent
import Vapor

protocol PushManageable {
    var pushProvider: PushProvider! { get }
    func sendPush(on request: Request, eventID: UUID, title: String, body: String, category: String) -> EventLoopFuture<Void>
}

extension PushManageable {
    func sendPush(on request: Request, eventID: UUID, title: String, body: String, category: String) -> EventLoopFuture<Void> {
        // Send push to any subscribers
        return NotificationEvent
            .query(on: request.db)
            .filter(\.$eventID == eventID)
            .first()
            .flatMap { event in
                if event != nil {
                    return event!.$pushToken.query(on: request.db).first().flatMap { pushToken in
                        return self.pushProvider.sendPush(on: request, notification: Notification(token: pushToken!.token, title: title, body: body, data: ["id": eventID.uuidString], category: category))
                    }
                }
                return request.eventLoop.makeSucceededFuture(())
        }
    }
}
