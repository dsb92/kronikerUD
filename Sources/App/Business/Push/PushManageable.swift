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
                if let event = event {
                    return event.$pushToken.query(on: request.db).first().flatMap { pushToken in
                        if let pushToken = pushToken {
                            return PushDevice.query(on: request.db)
                                .join(PushToken.self, on: \PushDevice.$pushToken.$id == \PushToken.$id)
                                .filter(PushToken.self, \PushToken.$id == pushToken.id!)
                                .first()
                                .flatMap() { pushDevice in
                                    if let pushDevice = pushDevice {
                                        return self.pushProvider.sendPush(on: request, notification: Notification(token: pushToken.token, title: title, body: body, data: ["id": eventID.uuidString], category: category), pushDevice: pushDevice)
                                    }
                                    return request.eventLoop.makeSucceededFuture(())
                                }
                        }
                        return request.eventLoop.makeSucceededFuture(())
                    }
                }
                return request.eventLoop.makeSucceededFuture(())
            }
    }
}
