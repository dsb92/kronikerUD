import Fluent
import Vapor

final class Channel: Model, Content {
    struct Input: Content {
        let text: String
    }

    struct Output: Content {
        var id: UUID?
        let deviceID: UUID
        let text: String
        let numberOfPosts: Int
        var createdAt: Date?
        var updatedAt: Date?
    }
    
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
}
