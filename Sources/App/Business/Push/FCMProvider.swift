import Vapor
import Fluent
import FCM

struct FCMProvider: PushProvider {
    func sendPush(on request: Request, notification: Notification, pushDevice: PushDevice) -> EventLoopFuture<Void> {
        let token = notification.token
        let fcmNotification: FCMNotification? = (notification.silent ?? false) ? nil : FCMNotification(title: notification.title, body: notification.body)
        
        let message = FCMMessage(token: token, notification: fcmNotification)
        message.apns = FCMApnsConfig(headers: [:], aps: FCMApnsApsObject(alert: nil, badge: pushDevice.appBadgeCount + 1, sound: "default", contentAvailable: notification.silent, category: notification.category, threadId: nil, mutableContent: notification.mutableContent))
        
        if let data = notification.data {
            message.data = data
        }
        
        let response = request.fcm.send(message, on: request.eventLoop).flatMap { response in
            return notification.create(on: request.db)
        }
        
        response.whenSuccess { _ in
            pushDevice.appBadgeCount = pushDevice.appBadgeCount + 1
            let _ = pushDevice.save(on: request.db)
        }
        
        response.whenFailure { error in
            //TODO: Send mail about failure or log somewhere...
            print(error)
        }
        
        return request.eventLoop.makeSucceededFuture(())
    }
}
