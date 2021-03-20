import Fluent
import Vapor

final class BlockedDevice: ApiModel {
    
    struct _Input: Content {
        let blockedDeviceID: UUID
    }
    
    struct _Output: Content {
        var id: UUID?
        let deviceID: UUID
        let blockedDeviceID: UUID
    }
    
    typealias Input = _Input
    typealias Output = _Output
    
    static let schema = "blocked_devices"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "device_id")
    var deviceID: UUID
    
    @Field(key: "blocked_device_id")
    var blockedDeviceID: UUID
    
    init() { }

    init(id: UUID? = nil, deviceID: UUID, blockedDeviceID: UUID) {
        self.id = id
        self.deviceID = deviceID
        self.blockedDeviceID = blockedDeviceID
    }
    
    // MARK: - api
    
    init(_ input: Input, _ headers: HttpHeaders) throws {
        self.deviceID = headers.deviceID
        self.blockedDeviceID = input.blockedDeviceID
    }
    
    func update(_ input: Input, _ headers: HttpHeaders) throws {
        self.deviceID = headers.deviceID
        self.blockedDeviceID = input.blockedDeviceID
    }
    
    var output: Output {
        .init(id: self.id, deviceID: self.deviceID, blockedDeviceID: self.blockedDeviceID)
    }
}
