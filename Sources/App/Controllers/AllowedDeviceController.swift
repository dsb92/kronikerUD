import Vapor
import Fluent

struct AllowedDeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let allowedDevices = routes.grouped("allowedDevices")
        allowedDevices.get("all", use: getAllAllowedDevices)
        allowedDevices.post("create", use: createAllowedDevice)
        allowedDevices.put("update", ":id", use: updateAllowedDevice)
        allowedDevices.delete("delete", ":id", use: deleteAllowedDevice)
    }
    
    func getAllAllowedDevices(req: Request)throws -> EventLoopFuture<[AllowedDevice]> {
        AllowedDevice.query(on: req.db).all()
    }
    
    func createAllowedDevice(req: Request)throws -> EventLoopFuture<AllowedDevice> {
        let allowedDevice = try req.content.decode(AllowedDevice.self)
        return allowedDevice.create(on: req.db).map { allowedDevice }
    }
    
    func updateAllowedDevice(req: Request)throws -> EventLoopFuture<AllowedDevice> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let input = try req.content.decode(AllowedDevice.self)
        return AllowedDevice.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { allowedDevice in
                allowedDevice.platform = input.platform
                allowedDevice.version = input.version
                return allowedDevice.save(on: req.db).map { allowedDevice }
            }
    }
    
    func deleteAllowedDevice(req: Request)throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return AllowedDevice.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
}
