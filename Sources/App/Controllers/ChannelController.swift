import Fluent
import Vapor

struct ChannelController: RouteCollection, PostManagable, BlockingManageable, ApiController {
    typealias Model = Channel
    
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "channels")
        
        let channels = routes.grouped("channels")
        channels.get(use: getChannels)
        channels.get("main", "posts", use: getMainChannelPosts)
        channels.post(":id", "posts", "create" , use: createPost)
        channels.get(":id", "posts" , use: getChannelPosts)
    }
    
    func getChannels(req: Request) throws -> EventLoopFuture<Page<Channel>> {
        Channel.query(on: req.db)
            .sort(\.$text)
            .paginate(for: req)
    }
    
    func getMainChannelPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        let posts = Post.query(on: req.db)
            .filter(\.$channel.$id == .null)
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
        return try getPostsBlockingManaged(posts: posts, req: req)
    }
    
    func getChannelPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let posts = Post.query(on: req.db)
            .filter(\.$channel.$id == id)
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
        return try getPostsBlockingManaged(posts: posts, req: req)
    }
    
    func createPost(req: Request) throws -> EventLoopFuture<Post.Output> {
        guard let channelID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return try createPost(req: req, channelID: channelID)
    }
    
    func deleteChannel(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing id in path")
        }
        return Channel
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Channel with id \(id) not found"))
            .flatMap { $0.delete(on: req.db) }
            .map { .noContent }
    }
}
