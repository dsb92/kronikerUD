import Fluent
import Vapor

final class AllowedDevice: ApiModel {
    
    struct _Input: Content {
        let version: String
        let platform: String
    }
    
    struct _Output: Content {
        var id: UUID?
        var version: String
        var platform: String
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
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
    
    // MARK: - api
    
    init(_ input: Input) throws {
        self.version = input.version
        self.platform = input.platform
    }
    
    func update(_ input: Input) throws {
        self.version = input.version
        self.platform = input.platform
    }
    
    var output: Output {
        .init(id: self.id, version: self.version, platform: self.platform)
    }
}
