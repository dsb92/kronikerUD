import Fluent
import Vapor

struct PostController: RouteCollection, PushManageable, CommentsManagable, PostManagable, BlockingManageable, ApiController {
    var pushProvider: PushProvider! = FCMProvider()
    typealias Model = Post
    
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "posts")
        
        let posts = routes.grouped("posts")
        let comments = routes.grouped("comments")
        
        posts.get(use: getPosts)
        posts.post("create", use: createPost)
        posts.post(":id", "comment", "create" , use: createComment)
        posts.get(":id", "comments", use: getComments)
        posts.delete(":id", "delete", use: deletePost)
        
        comments.delete(":id", "delete", use: deleteComment)
    }
    
    func getPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        let posts = Post.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
        return try getPostsBlockingManaged(posts: posts, req: req)
    }
    
    func getComments(req: Request) throws -> EventLoopFuture<Page<Comment>> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let comments = Comment.query(on: req.db)
            .filter(\.$post.$id == id)
            .with(\.$post)
            .sort(\.$createdAt)
            .paginate(for: req)
        return try getCommentsBlockingManaged(comments: comments, req: req)
    }
    
    func createPost(req: Request) throws -> EventLoopFuture<Post.Output> {
        try createPost(req: req, channelID: nil)
    }
    
    func createComment(req: Request) throws -> EventLoopFuture<Comment.Output> {
        guard let postID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Comment.Input.self)

        return Comment.query(on: req.db).filter(\.$post.$id == postID).filter(\.$deviceID == appHeaders.deviceID).first().flatMap { initialComment in
            if let initialComment = initialComment {
                let comment = Comment(postID: postID, deviceID: appHeaders.deviceID, text: input.text, rowID: initialComment.rowID)
                return createComment(req: req, comment: comment, postID: postID, deviceID: appHeaders.deviceID)
            } else {
                return Comment.query(on: req.db).filter(\.$post.$id == postID).count().flatMap { commentCount in
                    let comment = Comment(postID: postID, deviceID: appHeaders.deviceID, text: input.text, rowID: commentCount + 1)
                    return createComment(req: req, comment: comment, postID: postID, deviceID: appHeaders.deviceID)
                }
            }
        }
    }
    
    private func createComment(req: Request, comment: Comment, postID: UUID, deviceID: UUID) -> EventLoopFuture<Comment.Output> {
        comment.save(on: req.db).flatMap {
            return comment.$post.query(on: req.db).first().unwrap(or: Abort(.notFound, reason: "Post with id \(postID) no longer exists")).flatMap { post in
                return PushDevice.find(post.deviceID, on: req.db)
                    // Send push notification if needed
                    .flatMap { device in
                        guard let device = device else { return req.eventLoop.makeSucceededFuture(()) }
                        // Check if comment is created by owner of Post. We don't want to send push to ourselves :)
                        if device.id != deviceID {
                            return self.sendPush(on: req, eventID: postID, title: LocalizationManager.newCommentOnPost, body: comment.text, category: PushType.newCommentOnPost.rawValue)
                        }
                        return req.eventLoop.makeSucceededFuture(())
                    }
                    // Create or update my post filter
                    .flatMap {
                        PostFilter.query(on: req.db)
                            .join(Post.self, on: \PostFilter.$postID == \Post.$id)
                            .filter(\.$deviceID == deviceID)
                            .filter(\.$postID == post.id!)
                            .filter(\.$postFilterType == .myComments)
                            .first()
                            .flatMap { first in
                                guard first == nil else { return req.eventLoop.makeSucceededFuture(()) }
                                return PostFilter(postID: comment.$post.id, deviceID: deviceID, postFilterType: PostFilter.FilterType.myComments).create(on: req.db)
                            }
                    }
                    // Update number of comments
                    .flatMap {
                        addComment(numberOfComments: &post.numberOfComments)
                        return post.save(on: req.db)
                    }
                    .map { $0 }
            }
        }
        .map { Comment.Output(id: comment.id, deviceID: comment.deviceID, text: comment.text, rowID: comment.rowID, createdAt: comment.createdAt, updatedAt: comment.updatedAt) }
    }
    
    func deleteComment(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing id in path")
        }
        let appHeaders = try req.getAppHeaders()
        return Comment
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Comment with id \(id) not found"))
            .flatMap { comment in
                comment.$post.query(on: req.db).first().unwrap(or: Abort(.notFound, reason: "Comment doesn't belong to a post anymore")).flatMap { post in
                    // Delete associate filters
                    PostFilter.query(on: req.db)
                        .filter(\.$postID == post.id!)
                        .filter(\.$deviceID == appHeaders.deviceID)
                        .filter(\.$postFilterType == .myComments)
                        .delete()
                        .flatMap {
                            // Delete comment
                            return comment.delete(on: req.db).flatMap {
                                // Update numberOfComments
                                deleteComment(numberOfComments: &post.numberOfComments)
                                return post.save(on: req.db)
                            }
                        }
                }
            }
            .map { .noContent }
    }
    
    func deletePost(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing id in path")
        }
        let appHeaders = try req.getAppHeaders()
        return Post
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Post with id \(id) not found"))
            .flatMap { post in
                // Delete associated notification events
                NotificationEvent.query(on: req.db)
                    .filter(\.$eventID == post.id!)
                    .delete()
                    .flatMap {
                    // Delete associate filters
                    PostFilter.query(on: req.db)
                        .filter(\.$postID == post.id!)
                        .filter(\.$deviceID == appHeaders.deviceID)
                        .filter(\.$postFilterType == .myPost)
                        .delete()
                        .flatMap {
                        // Delete post
                        post.delete(on: req.db).flatMap {
                            // Update numberOfPosts if post belongs to a channel
                            return post.$channel.query(on: req.db).first().flatMap { channel in
                                guard let channel = channel else { return req.eventLoop.makeSucceededFuture(()) }
                                deletePost(numberOfPosts: &channel.numberOfPosts)
                                return channel.save(on: req.db)
                            }
                        }
                    }
                }
            }
            .map { .noContent }
    }
}
