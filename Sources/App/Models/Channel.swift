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
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, deviceID: UUID, text: String, updatedAt: Date? = nil) {
        self.id = id
        self.deviceID = deviceID
        self.text = text
        self.updatedAt = updatedAt
    }
}
