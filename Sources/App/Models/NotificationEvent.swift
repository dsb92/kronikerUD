import Fluent
import Vapor

final class NotificationEvent: ApiModel {
    
    struct _Input: Content {
        let eventID: UUID
        let pushTokenID: UUID
    }
    
    struct _Output: Content {
        var id: UUID?
        let eventID: UUID
        let pushToken: PushToken
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "notification_events"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "push_token_id")
    var pushToken: PushToken
    
    @Field(key: "event_id")
    var eventID: UUID
    
    init() { }

    init(id: UUID? = nil, pushTokenID: UUID, eventID: UUID) {
        self.id = id
        self.$pushToken.id = pushTokenID
        self.eventID = eventID
    }
    
    // MARK: - api
    
    init(_ input: Input, _: HttpHeaders) throws {
        self.$pushToken.id = input.pushTokenID
        self.eventID = input.eventID
    }
    
    func update(_ input: Input, _: HttpHeaders) throws {
        self.$pushToken.id = input.pushTokenID
        self.eventID = input.eventID
    }
    
    var output: Output {
        .init(id: self.id, eventID: self.eventID, pushToken: self.pushToken)
    }
}
