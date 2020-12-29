import Fluent
import Vapor

struct PostController: RouteCollection, PushManageable, CommentsManagable, PostManagable {
    var pushProvider: PushProvider! = FCMProvider()
    
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        let comments = routes.grouped("comments")
        
        posts.get(use: getPosts)
        posts.get(":id", use: getPost)
        posts.post("create", use: createPost)
        posts.post(":id", "comment", "create" , use: createComment)
        posts.get(":id", "comments", use: getComments)
        posts.delete(":id", "delete", use: deletePost)
        
        comments.delete(":id", "delete", use: deleteComment)
    }
    
    func getPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        Post.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
    }
    
    func getComments(req: Request) throws -> EventLoopFuture<Page<Comment>> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Comment.query(on: req.db)
            .filter(\.$post.$id == id)
            .with(\.$post)
            .sort(\.$createdAt)
            .paginate(for: req)
    }
    
    func getPost(req: Request) throws -> EventLoopFuture<Post.Output> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        return Post.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { Post.Output(id: $0.id, deviceID: $0.deviceID, text: $0.text, numberOfComments: $0.numberOfComments, createdAt: $0.createdAt, updatedAt: $0.updatedAt, channelID: $0.$channel.id) }
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
                            return self.sendPush(on: req, eventID: postID, title: LocalizationManager.newCommentOnPost, body: comment.text, category: PushType.newCommentOnPost.rawValue).transform(to: ())
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
        return Comment
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Comment with id \(id) not found"))
            .flatMap { comment in
                comment.$post.query(on: req.db).first().unwrap(or: Abort(.notFound, reason: "Comment doesn't belong to a post anymore")).flatMap { post in
                    return comment.delete(on: req.db).flatMap {
                        deleteComment(numberOfComments: &post.numberOfComments)
                        return post.update(on: req.db)
                    }
                }
            }
            .map { .noContent }
    }
    
    func deletePost(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing id in path")
        }
        return Post
            .find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Post with id \(id) not found"))
            .flatMap { post in
                // Delete associated notification events
                NotificationEvent.query(on: req.db).filter(\.$eventID == post.id!).delete().flatMap {
                    // Delete associate filters
                    PostFilter.query(on: req.db).filter(\.$postID == post.id!).delete().flatMap {
                        // Delete post
                        post.delete(on: req.db)
                    }
                }
            }
            .map { .noContent }
    }
}
