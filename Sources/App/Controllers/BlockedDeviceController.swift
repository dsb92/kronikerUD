import Vapor
import Fluent

struct CheckForBlockedCommentsResponse: Content {
    let blockedByYou: [Comment]
    let blockedFromYou: [Comment]
}

struct BlockedDeviceController: RouteCollection, ApiController {
    typealias Model = BlockedDevice
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "blockedDevices")
        
        let blockedDevices = routes.grouped("blockedDevices")
        
        blockedDevices.get("posts", ":id", "comments", use: getBlockedComments)
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
    
    func getBlockedComments(req: Request) throws -> EventLoopFuture<CheckForBlockedCommentsResponse> {
        let appHeaders = try req.getAppHeaders()
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let commentsBlockedByYou = Post.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.$comments.query(on: req.db)
                .join(BlockedDevice.self, on: \Comment.$deviceID == \BlockedDevice.$blockedDeviceID)
                .filter(BlockedDevice.self, \BlockedDevice.$deviceID == appHeaders.deviceID)
                .all()
            }
        
        let commentsBlockedFromYou = Post.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap {
                $0.$comments.query(on: req.db)
                .join(BlockedDevice.self, on: \Comment.$deviceID == \BlockedDevice.$deviceID)
                .filter(BlockedDevice.self, \BlockedDevice.$blockedDeviceID == appHeaders.deviceID)
                .all()
            }
        
        return commentsBlockedByYou.flatMap { blockedByYou in
            return commentsBlockedFromYou.flatMap { blockedFromYou in
                return req.eventLoop.makeSucceededFuture(CheckForBlockedCommentsResponse(blockedByYou: blockedByYou, blockedFromYou: blockedFromYou))
            }
        }
    }
}
