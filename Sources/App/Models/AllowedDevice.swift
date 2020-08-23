import Fluent
import Vapor

final class AllowedDevice: Model, Content {
    static let schema = "allowed_devices"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "version")
    var version: String
    
    @Field(key: "platform")
    var platform: String
    
    init() { }

    init(id: UUID? = nil, version: String, platform: String) {
        self.id = id
        self.version = version
        self.platform = platform
    }
}
