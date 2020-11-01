import Fluent
import Vapor

struct PostController: RouteCollection, PushManageable {
    var pushProvider: PushProvider! = FCMProvider()
    
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get(use: getPosts)
        posts.get(":id", use: getPost)
        posts.post("create", use: createPost)
        posts.post(":id", "comment", "create" , use: createComment)
        posts.get(":id", "comments", use: getComments)
    }
    
    func getPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        Post.query(on: req.db).sort(\.$updatedAt, .descending).paginate(for: req)
    }
    
    func getComments(req: Request) throws -> EventLoopFuture<Page<Comment>> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Comment.query(on: req.db).filter(\.$post.$id == id).sort(\.$updatedAt).paginate(for: req)
    }
    
    func getPost(req: Request) throws -> EventLoopFuture<Post.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Post.find(id, on: req.db).unwrap(or: Abort(.notFound)).map { Post.Output(id: $0.id, deviceID: $0.deviceID, text: $0.text, updatedAt: $0.updatedAt, channelID: $0.$channel.id) }
    }
    
    func createPost(req: Request) throws -> EventLoopFuture<Post.Output> {
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Post.Input.self)
        let post = Post(deviceID: appHeaders.deviceID, text: input.text)
        return post.save(on: req.db).flatMap {
            return PushDevice.find(appHeaders.deviceID, on: req.db)
                .flatMap { device in
                    guard let device = device else { return req.eventLoop.makeSucceededFuture(()) }
                    let event = NotificationEvent(pushTokenID: device.$pushToken.id, eventID: post.id!)
                    return event.save(on: req.db)
                }
                .flatMap { // Create or update my post filter
                    return PostFilter(postID: post.id!, deviceID: post.deviceID, postFilterType: PostFilter.FilterType.myPost).create(on: req.db)
                }
                .map { Post.Output(id: post.id, deviceID: post.deviceID, text: post.text, updatedAt: post.updatedAt) }
        }
    }
    
    func createComment(req: Request) throws -> EventLoopFuture<Comment.Output> {
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Comment.Input.self)
        let comment = Comment(postID: postID, deviceID: appHeaders.deviceID, text: input.text)
        return comment.save(on: req.db).flatMap {
            return comment.$post.query(on: req.db).first().flatMap { post in
                return PushDevice.find(post!.deviceID, on: req.db)
                    .flatMap { device in
                        guard let device = device else { return req.eventLoop.makeSucceededFuture(()) }
                        // Check if comment is created by owner of Post. We don't want to send push to ourselves :)
                        if device.id != appHeaders.deviceID {
                            return self.sendPush(on: req, eventID: postID, title: LocalizationManager.newCommentOnPost, body: comment.text, category: PushType.newCommentOnPost.rawValue).transform(to: ())
                        }
                        return req.eventLoop.makeSucceededFuture(())
                    }
                    .flatMap { // Create or update my post filter
                        return PostFilter.query(on: req.db)
                            .join(Post.self, on: \PostFilter.$postID == \Post.$id)
                            .filter(\.$deviceID == appHeaders.deviceID)
                            .filter(\.$postID == post!.id!)
                            .filter(\.$postFilterType == .myComments)
                            .first()
                            .flatMap { first in
                                guard first == nil else { return req.eventLoop.makeSucceededFuture(()) }
                                return PostFilter(postID: comment.$post.id, deviceID: appHeaders.deviceID, postFilterType: PostFilter.FilterType.myComments).create(on: req.db)
                            }
                    }
                    .map { $0 }
            }
        }
        .map { Comment.Output(id: comment.id, deviceID: comment.deviceID, text: comment.text, updatedAt: comment.updatedAt) }
    }
}
