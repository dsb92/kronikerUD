import Fluent
import Vapor

struct ChannelController: RouteCollection, PostManagable {
    func boot(routes: RoutesBuilder) throws {
        let channels = routes.grouped("channels")
        channels.get(use: getChannels)
        channels.get("main", "posts", use: getMainChannelPosts)
        channels.get(":id", use: getChannel)
        channels.post("create", use: createChannel)
        channels.post(":id", "posts", "create" , use: createPost)
        channels.get(":id", "posts" , use: getChannelPosts)
    }
    
    func getChannels(req: Request) throws -> EventLoopFuture<Page<Channel>> {
        Channel.query(on: req.db)
            .sort(\.$text)
            .paginate(for: req)
    }
    
    func getMainChannelPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        Post.query(on: req.db)
            .filter(\.$channel.$id == .null)
            .sort(\.$updatedAt, .descending)
            .paginate(for: req)
    }
    
    func getChannelPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Post.query(on: req.db)
            .filter(\.$channel.$id == id)
            .sort(\.$updatedAt, .descending)
            .paginate(for: req)
    }
    
    func getChannel(req: Request) throws -> EventLoopFuture<Channel.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Channel.find(id, on: req.db).unwrap(or: Abort(.notFound)).map { Channel.Output(id: $0.id, deviceID: $0.deviceID, text: $0.text, updatedAt: $0.updatedAt) }
    }
    
    func createChannel(req: Request) throws -> EventLoopFuture<Channel.Output> {
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Channel.Input.self)
        let channel = Channel(deviceID: appHeaders.deviceID, text: input.text)
        return channel.save(on: req.db).map { Channel.Output(id: channel.id, deviceID: channel.deviceID, text: channel.text, updatedAt: channel.updatedAt) }
    }
    
    func createPost(req: Request) throws -> EventLoopFuture<Post.Output> {
        guard let channelID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return try createPost(req: req, channelID: channelID)
    }
}
