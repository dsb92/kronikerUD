import Fluent
import Vapor

final class PushToken: ApiModel {
    
    struct _Input: Content {
        let token: String
    }
    
    struct _Output: Content {
        var id: UUID?
        let token: String
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "push_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Children(for: \.$pushToken)
    var notificationEvents: [NotificationEvent]
    
    @Field(key: "token")
    var token: String
    
    init() { }

    init(id: UUID? = nil, token: String) {
        self.id = id
        self.token = token
    }
    
    // MARK: - api
    
    init(_ input: Input) throws {
        self.token = input.token
    }
    
    func update(_ input: Input) throws {
        self.token = input.token
    }
    
    var output: Output {
        .init(id: self.id, token: self.token)
    }
}
