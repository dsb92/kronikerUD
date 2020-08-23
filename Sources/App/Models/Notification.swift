import Fluent
import Vapor

typealias NotificationPayload = [String: String]

final class Notification: ApiModel {
    
    struct _Input: Content {
        let token: String
        let title: String
        let body: String
        var data: NotificationPayload?
        var category: String?
        var silent: Bool?
        var mutableContent: Bool?
    }
    
    struct _Output: Content {
        var id: UUID?
        let token: String
        let title: String
        let body: String
        var data: NotificationPayload?
        var category: String?
        var silent: Bool?
        var mutableContent: Bool?
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "notifications"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "body")
    var body: String
    
    @OptionalField(key: "data")
    var data: NotificationPayload?
    
    @OptionalField(key: "category")
    var category: String?
    
    @OptionalField(key: "silent")
    var silent: Bool?
    
    @OptionalField(key: "mutable_content")
    var mutableContent: Bool?
    
    init() { }

    init(id: UUID? = nil, token: String, title: String, body: String, data: NotificationPayload? = nil, category: String? = nil, silent: Bool? = nil, mutableContent: Bool? = nil) {
        self.id = id
        self.token = token
        self.title = title
        self.body = body
        self.data = data
        self.category = category
        self.silent = silent
        self.mutableContent = mutableContent
    }
    
    // MARK: - api
    
    init(_ input: Input) throws {
        self.token = input.token
        self.title = input.title
        self.body = input.body
        self.data = input.data
        self.category = input.category
        self.silent = input.silent
        self.mutableContent = input.mutableContent
    }
    
    func update(_ input: Input) throws {
        self.token = input.token
        self.title = input.title
        self.body = input.body
        self.data = input.data
        self.category = input.category
        self.silent = input.silent
        self.mutableContent = input.mutableContent
    }
    
    var output: Output {
        .init(id: self.id, token: self.token, title: self.title, body: self.body, data: self.data, category: self.category, silent: self.silent, mutableContent: self.mutableContent)
    }
}
