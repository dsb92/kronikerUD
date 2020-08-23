import Vapor
import Fluent

struct PushDeviceController: RouteCollection, ApiController {
    typealias Model = PushDevice
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "pushDevices")
    }
    
    func readAll(_ req: Request) throws -> EventLoopFuture<Page<PushDevice._Output>> {
        PushDevice.query(on: req.db).with(\.$pushToken).paginate(for: req).map { $0.map { $0.output } }
    }
}
