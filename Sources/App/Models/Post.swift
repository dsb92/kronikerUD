import Fluent
import Vapor

final class Post: Model, Content {
    struct Input: Content {
        let text: String
        var channelID: UUID?
    }

    struct Output: Content {
        var id: UUID?
        let deviceID: UUID
        let text: String
        let numberOfComments: Int
        var createdAt: Date?
        var updatedAt: Date?
        var channelID: UUID?
    }
    
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Children(for: \.$post)
    var comments: [Comment]
    
    @Field(key: "device_id")
    var deviceID: UUID
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "numberOfComments")
    var numberOfComments: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @OptionalParent(key: "channel_id")
    var channel: Channel?
    
    init() { }

    init(id: UUID? = nil, channelID: UUID? = nil, deviceID: UUID, text: String, numberOfComments: Int, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$channel.id = channelID
        self.deviceID = deviceID
        self.text = text
        self.numberOfComments = numberOfComments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
