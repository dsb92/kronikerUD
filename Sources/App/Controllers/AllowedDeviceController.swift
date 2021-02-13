import Vapor
import Fluent

struct AllowedDeviceController: RouteCollection, ApiController {
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "allowedDevices")
    }
}
