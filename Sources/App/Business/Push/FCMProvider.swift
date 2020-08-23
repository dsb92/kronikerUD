import Vapor
import Fluent
import FCM

struct FCMProvider: PushProvider {
    func sendPush(on request: Request, notification: Notification) -> EventLoopFuture<Notification> {
        let token = notification.token
        let fcmNotification: FCMNotification? = (notification.silent ?? false) ? nil : FCMNotification(title: notification.title, body: notification.body)
        let message = FCMMessage(token: token, notification: fcmNotification)
        message.apns = FCMApnsConfig(headers: [:], aps: FCMApnsApsObject(alert: nil, badge: nil, sound: nil, contentAvailable: notification.silent, category: notification.category, threadId: nil, mutableContent: notification.mutableContent))
        
        if let data = notification.data {
            message.data = data
        }
        
        return request.fcm.send(message, on: request.eventLoop).flatMap { response in
            return notification.create(on: request.db)
        }.map { notification }
    }
}
