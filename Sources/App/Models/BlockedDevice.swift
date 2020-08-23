import Fluent
import Vapor

final class BlockedDevice: Model, Content {
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
}
