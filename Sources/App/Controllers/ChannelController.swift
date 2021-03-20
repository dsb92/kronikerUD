import Fluent
import Vapor

struct ChannelController: RouteCollection, PostManagable, BlockingManageable {
    func boot(routes: RoutesBuilder) throws {
        let channels = routes.grouped("channels")
        channels.get(use: getChannels)
        channels.get("main", "posts", use: getMainChannelPosts)
        channels.get(":id", use: getChannel)
        channels.post("create", use: createChannel)
        channels.post(":id", "posts", "create" , use: createPost)
        channels.get(":id", "posts" , use: getChannelPosts)
        channels.delete(":id", "posts", "delete" , use: deleteChannel)
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
    
    func getChannel(req: Request) throws -> EventLoopFuture<Channel.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Channel.find(id, on: req.db).unwrap(or: Abort(.notFound)).map { Channel.Output(id: $0.id, deviceID: $0.deviceID, text: $0.text, numberOfPosts: $0.numberOfPosts, createdAt: $0.createdAt, updatedAt: $0.updatedAt) }
    }
    
    func createChannel(req: Request) throws -> EventLoopFuture<Channel.Output> {
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Channel.Input.self)
        let channel = Channel(deviceID: appHeaders.deviceID, text: input.text, numberOfPosts: 0)
        return channel.save(on: req.db).map { Channel.Output(id: channel.id, deviceID: channel.deviceID, text: channel.text, numberOfPosts: channel.numberOfPosts, createdAt: channel.createdAt, updatedAt: channel.updatedAt) }
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
