import Vapor
import Fluent

struct PushDeviceController: RouteCollection, ApiController {
    typealias Model = PushDevice
    func boot(routes: RoutesBuilder) throws {
        let pushDevices = setup(routes: routes, on: "pushDevices")
        pushDevices.put("resetBadgeCount", use: resetBadgeCount)
    }
    
    func readAll(_ req: Request) throws -> EventLoopFuture<Page<PushDevice._Output>> {
        PushDevice.query(on: req.db).with(\.$pushToken).paginate(for: req).map { $0.map { $0.output } }
    }
    
    func resetBadgeCount(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let appHeaders = try req.getAppHeaders()
        return PushDevice
            .find(appHeaders.deviceID, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Device not found"))
            .flatMap { existing in
                existing.appBadgeCount = 0
                return existing.save(on: req.db)
            }
            .map { .noContent }
    }
}
