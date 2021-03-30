import Fluent
import Vapor

final class Channel: ApiModel {
    struct _Input: Content {
        let text: String
    }

    struct _Output: Content {
        var id: UUID?
        let deviceID: UUID
        let text: String
        let numberOfPosts: Int
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "channels"
    
    @ID(key: .id)
    var id: UUID?
    
    @Children(for: \.$channel)
    var posts: [Post]
    
    @Field(key: "device_id")
    var deviceID: UUID
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "numberOfPosts")
    var numberOfPosts: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, deviceID: UUID, text: String, numberOfPosts: Int, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.deviceID = deviceID
        self.text = text
        self.numberOfPosts = numberOfPosts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - api
    
    init(_ input: Input, _ headers: HttpHeaders) throws {
        self.text = input.text
        self.deviceID = headers.deviceID
        self.numberOfPosts = 0
    }
    
    func update(_ input: Input, _ headers: HttpHeaders) throws {
        self.text = input.text
        self.deviceID = headers.deviceID
    }
    
    var output: Output {
        .init(id: self.id, deviceID: self.deviceID, text: self.text, numberOfPosts: self.numberOfPosts, createdAt: self.createdAt, updatedAt: self.updatedAt)
    }
}
