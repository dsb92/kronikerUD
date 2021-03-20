import Fluent
import Vapor

protocol BlockingManageable {
    func getPostsBlockingManaged(posts: EventLoopFuture<Page<Post>>, req: Request) throws -> EventLoopFuture<Page<Post>>
    func getCommentsBlockingManaged(comments: EventLoopFuture<Page<Comment>>, req: Request) throws -> EventLoopFuture<Page<Comment>>
}


extension BlockingManageable {
    func getPostsBlockingManaged(posts: EventLoopFuture<Page<Post>>, req: Request) throws -> EventLoopFuture<Page<Post>> {
        let appHeaders = try req.getAppHeaders()
        return posts.flatMap { paginated in
            // Find all posts that are blocked BY you
            return Post
                .query(on: req.db)
                .join(BlockedDevice.self, on: \Post.$deviceID == \BlockedDevice.$blockedDeviceID)
                .filter(BlockedDevice.self, \BlockedDevice.$deviceID == appHeaders.deviceID)
                .all()
                .flatMap { blockedPosts in
                    // Filter them out removing those that should not be visible to requester
                    var items = paginated.items.filter { post -> Bool in
                        return blockedPosts.contains { blockedPost -> Bool in
                            blockedPost.id == post.id
                        } == false
                    }
                    // Find all posts that are blocked FROM you
                    return Post
                        .query(on: req.db)
                        .join(BlockedDevice.self, on: \Post.$deviceID == \BlockedDevice.$deviceID)
                        .filter(BlockedDevice.self, \BlockedDevice.$blockedDeviceID == appHeaders.deviceID)
                        .all()
                        .flatMap { blockedPosts in
                            // Filter them out removing those that should not be visible to requester
                            items = items.filter { post -> Bool in
                                return blockedPosts.contains { blockedPost -> Bool in
                                    blockedPost.id == post.id
                                } == false
                            }
                            
                            return req.eventLoop.makeSucceededFuture(Page(items: items, metadata: paginated.metadata))
                        }
                }
        }
    }
    
    func getCommentsBlockingManaged(comments: EventLoopFuture<Page<Comment>>, req: Request) throws -> EventLoopFuture<Page<Comment>> {
        let appHeaders = try req.getAppHeaders()
        return comments.flatMap { paginated in
            // Find all comments that are blocked BY you
            return Comment
                .query(on: req.db)
                .join(BlockedDevice.self, on: \Comment.$deviceID == \BlockedDevice.$blockedDeviceID)
                .filter(BlockedDevice.self, \BlockedDevice.$deviceID == appHeaders.deviceID)
                .all()
                .flatMap { blockedComments in
                    // Filter them out removing those that should not be visible to requester
                    var items = paginated.items.filter { comment -> Bool in
                        return blockedComments.contains { blockedComment -> Bool in
                            blockedComment.id == comment.id
                        } == false
                    }
                    // Find all comments that are blocked FROM you
                    return Comment
                        .query(on: req.db)
                        .join(BlockedDevice.self, on: \Comment.$deviceID == \BlockedDevice.$deviceID)
                        .filter(BlockedDevice.self, \BlockedDevice.$blockedDeviceID == appHeaders.deviceID)
                        .all()
                        .flatMap { blockedComments in
                            // Filter them out removing those that should not be visible to requester
                            items = items.filter { comment -> Bool in
                                return blockedComments.contains { blockedComment -> Bool in
                                    blockedComment.id == comment.id
                                } == false
                            }
                            
                            return req.eventLoop.makeSucceededFuture(Page(items: items, metadata: paginated.metadata))
                        }
                }
        }
    }
}
