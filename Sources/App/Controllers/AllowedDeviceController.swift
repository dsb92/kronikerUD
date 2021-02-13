import Vapor
import Fluent

struct AllowedDeviceController: RouteCollection, ApiController {
    typealias Model = AllowedDevice
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "allowedDevices")
    }
}
