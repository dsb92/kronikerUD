import Fluent
import Vapor

final class PushDevice: ApiModel {
    
    struct _Input: Content {
        let appVersion: String
        let appPlatform: String
        let appBadgeCount: Int
        let pushTokenID: UUID
    }
    
    struct _Output: Content {
        var id: UUID?
        let appVersion: String
        let appPlatform: String
        let appBadgeCount: Int
        let pushToken: PushToken
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "push_devices"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "app_version")
    var appVersion: String
    
    @Field(key: "app_platform")
    var appPlatform: String
    
    @Field(key: "app_badge_count")
    var appBadgeCount: Int
    
    @Parent(key: "push_token_id")
    var pushToken: PushToken
    
    init() { }

    init(id: UUID? = nil, appVersion: String, appPlatform: String, pushTokenID: UUID, appBadgeCount: Int) {
        self.id = id
        self.appVersion = appVersion
        self.appPlatform = appPlatform
        self.appBadgeCount = appBadgeCount
        self.$pushToken.id = pushTokenID
    }
    
    // MARK: - api
    
    init(_ input: Input, _: HttpHeaders) throws {
        self.appVersion = input.appVersion
        self.appPlatform = input.appPlatform
        self.appBadgeCount = input.appBadgeCount
        self.$pushToken.id = input.pushTokenID
    }
    
    func update(_ input: Input, _: HttpHeaders) throws {
        self.appVersion = input.appVersion
        self.appPlatform = input.appPlatform
        self.appBadgeCount = input.appBadgeCount
        self.$pushToken.id = input.pushTokenID
    }
    
    var output: Output {
        .init(id: self.id, appVersion: self.appVersion, appPlatform: self.appPlatform, appBadgeCount: self.appBadgeCount, pushToken: self.pushToken)
    }
}
