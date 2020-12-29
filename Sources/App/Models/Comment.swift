import Fluent
import Vapor

final class Comment: Model, Content {
    struct Input: Content {
        let text: String
    }

    struct Output: Content {
        var id: UUID?
        let deviceID: UUID
        let text: String
        let rowID: Int
        var createdAt: Date?
        var updatedAt: Date?
    }
    
    static let schema = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "post_id")
    var post: Post
    
    @Field(key: "device_id")
    var deviceID: UUID
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "row_id")
    var rowID: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }

    init(id: UUID? = nil, postID: UUID, deviceID: UUID, text: String, rowID: Int, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$post.id = postID
        self.deviceID = deviceID
        self.text = text
        self.rowID = rowID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
