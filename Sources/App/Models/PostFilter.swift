import Fluent
import Vapor

// model definition
extension FieldKey {
    static var postFilterType: Self { "postFilterType" }
}

final class PostFilter: ApiModel {
    enum FilterType: String, Codable, CaseIterable {
        static var name: FieldKey { .postFilterType }

        case myPost
        case myComments
        //How to add new fields using migrations: https://github.com/vapor/fluent-kit/releases/tag/1.0.0-beta.5
    }
    
    struct _Input: Content {
        let postID: UUID
        let deviceID: UUID
        let postFilterType: PostFilter.FilterType
    }

    struct _Output: Content {
        var id: UUID?
        let deviceID: UUID
        let postID: UUID
        let type: PostFilter.FilterType
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "postFilters"
    
    @ID(key: .id)
    var id: UUID?
    
    @Enum(key: .postFilterType)
    var postFilterType: PostFilter.FilterType
    
    @Field(key: "post_id")
    var postID: UUID
    
    @Field(key: "device_id")
    var deviceID: UUID
    
    init() { }

    init(id: UUID? = nil, postID: UUID, deviceID: UUID, postFilterType: PostFilter.FilterType) {
        self.id = id
        self.postID = postID
        self.deviceID = deviceID
        self.postFilterType = postFilterType
    }
    
    // MARK: - api
    
    init(_ input: Input) throws {
        self.postID = input.postID
        self.deviceID = input.deviceID
        self.postFilterType = input.postFilterType
    }
    
    func update(_ input: Input) throws {
        self.postID = input.postID
        self.deviceID = input.deviceID
        self.postFilterType = input.postFilterType
    }
    
    var output: Output {
        .init(id: self.id, deviceID: self.deviceID, postID: self.postID, type: self.postFilterType)
    }
}
