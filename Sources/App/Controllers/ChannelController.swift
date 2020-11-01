import Fluent
import Vapor

struct ChannelController: RouteCollection {
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
        return Channel.query(on: req.db)
            .sort(\.$text)
            .paginate(for: req)
    }
    
    func getMainChannelPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        return Post.query(on: req.db)
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
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Post.Input.self)
        let post = Post(channelID: channelID, deviceID: appHeaders.deviceID, text: input.text)
        return post.save(on: req.db).flatMap {
            return PushDevice.find(appHeaders.deviceID, on: req.db)
                .flatMap { device in
                    if device != nil {
                        let event = NotificationEvent(pushTokenID: device!.$pushToken.id, eventID: post.id!)
                        return event.save(on: req.db)
                    }
                    return req.eventLoop.makeSucceededFuture(())
                }
                .flatMap { // Create or update my post filter
                    return PostFilter(postID: post.id!, deviceID: post.deviceID, postFilterType: PostFilter.FilterType.myPost).create(on: req.db)
                }
                .map { Post.Output(id: post.id, deviceID: post.deviceID, text: post.text, updatedAt: post.updatedAt, channelID: post.$channel.id) }
        }
    }
}
