import Fluent
import Vapor

protocol PushProvider {
    func sendPush(on request: Request, notification: Notification) -> EventLoopFuture<Notification>
}
