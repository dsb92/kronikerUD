import Fluent
import Vapor

final class Post: ApiModel {
    
    struct _Input: Content {
        let text: String
        var channelID: UUID?
        var subjectText: String?
    }

    struct _Output: Content {
        var id: UUID?
        let deviceID: UUID
        let text: String
        let numberOfComments: Int
        var createdAt: Date?
        var updatedAt: Date?
        var channelID: UUID?
        var subjectText: String?
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
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
    
    @OptionalField(key: "subject_text")
    var subjectText: String?
    
    init() { }

    init(id: UUID? = nil, channelID: UUID? = nil, deviceID: UUID, text: String, numberOfComments: Int, subjectText: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$channel.id = channelID
        self.deviceID = deviceID
        self.text = text
        self.numberOfComments = numberOfComments
        self.subjectText = subjectText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - api
    
    init(_ input: Input, _ headers: HttpHeaders) throws {
        self.text = input.text
        self.$channel.id = input.channelID
        self.deviceID = headers.deviceID
        self.numberOfComments = 0
        self.subjectText = input.subjectText
    }
    
    func update(_ input: Input, _ headers: HttpHeaders) throws {
        self.text = input.text
        self.$channel.id = input.channelID
        self.deviceID = headers.deviceID
        self.subjectText = input.subjectText
    }
    
    var output: Output {
        .init(id: self.id, deviceID: self.deviceID, text: self.text, numberOfComments: self.numberOfComments, createdAt: self.createdAt, updatedAt: self.updatedAt, channelID: self.$channel.id, subjectText: self.subjectText)
    }
}
