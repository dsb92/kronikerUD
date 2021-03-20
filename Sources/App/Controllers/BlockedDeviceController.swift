import Vapor
import Fluent

struct BlockedDeviceController: RouteCollection, ApiController {
    typealias Model = BlockedDevice
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "blockedDevices")
    }
    
    func create(req: Request) throws -> EventLoopFuture<BlockedDevice._Output> {
        let request = try req.content.decode(Model.Input.self)
        let headers = try req.getAppHeaders()
        let model = try Model(request, headers)
        // Ignore blocking if deviceID and blockedDeviceID are identical (meaning trying to block yourself)
        if model.deviceID == model.blockedDeviceID {
            throw Abort(.badRequest, reason: "You cannot block yourself")
        }
        return model.save(on: req.db).map { _ in model.output }
    }
}
