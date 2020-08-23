import Fluent
import Vapor

protocol ApiController {
    var idKey: String { get }

    associatedtype Model: ApiModel

    // generic helper functions
    func getId(_: Request) throws -> Model.IDValue
    func find(_: Request) throws -> EventLoopFuture<Model>

    // generic crud methods
    func create(_: Request) throws -> EventLoopFuture<Model.Output>
    func readAll(_: Request) throws -> EventLoopFuture<Page<Model.Output>>
    func read(_: Request) throws -> EventLoopFuture<Model.Output>
    func update(_: Request) throws -> EventLoopFuture<Model.Output>
    func delete(_: Request) throws -> EventLoopFuture<HTTPStatus>
    
    // router helper
    @discardableResult
    func setup(routes: RoutesBuilder, on endpoint: String) -> RoutesBuilder
}

extension ApiController where Model.IDValue: LosslessStringConvertible {

    func getId(_ req: Request) throws -> Model.IDValue {
        guard let id = req.parameters.get(self.idKey, as: Model.IDValue.self) else {
            throw Abort(.badRequest)
        }
        return id
    }
}

extension ApiController {
    
    var idKey: String { "id" }

    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        Model.find(try self.getId(req), on: req.db).unwrap(or: Abort(.notFound))
    }

    func create(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let request = try req.content.decode(Model.Input.self)
        let model = try Model(request)
        return model.save(on: req.db).map { _ in model.output }
    }
    
    func readAll(_ req: Request) throws -> EventLoopFuture<Page<Model.Output>> {
        Model.query(on: req.db).paginate(for: req).map { $0.map { $0.output } }
    }

    func read(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        try self.find(req).map { $0.output }
    }

    func update(_ req: Request) throws -> EventLoopFuture<Model.Output> {
        let request = try req.content.decode(Model.Input.self)
        return try self.find(req).flatMapThrowing { model -> Model in
            try model.update(request)
            return model
        }
        .flatMap { model in
            return model.update(on: req.db).map { model.output }
        }
    }
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try self.find(req).flatMap { $0.delete(on: req.db) }.map { .ok }
    }
    
    @discardableResult
    func setup(routes: RoutesBuilder, on endpoint: String) -> RoutesBuilder {
        let base = routes.grouped(PathComponent(stringLiteral: endpoint))
        let idPathComponent = PathComponent(stringLiteral: ":\(self.idKey)")
        
        base.post(use: self.create)
        base.get(use: self.readAll)
        base.get(idPathComponent, use: self.read)
        base.post(idPathComponent, use: self.update)
        base.delete(idPathComponent, use: self.delete)

        return base
    }
}
