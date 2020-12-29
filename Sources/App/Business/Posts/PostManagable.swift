import Fluent
import Vapor

protocol PostManagable {
    func createPost(req: Request, channelID: UUID?) throws -> EventLoopFuture<Post.Output>
}

extension PostManagable {
    func createPost(req: Request, channelID: UUID?) throws -> EventLoopFuture<Post.Output> {
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(Post.Input.self)
        let post = Post(channelID: channelID, deviceID: appHeaders.deviceID, text: input.text, numberOfComments: 0)
        return post.save(on: req.db).flatMap {
            PushDevice.find(appHeaders.deviceID, on: req.db)
                .flatMap { device in
                    guard let device = device else { return req.eventLoop.makeSucceededFuture(()) }
                    let event = NotificationEvent(pushTokenID: device.$pushToken.id, eventID: post.id!)
                    return event.save(on: req.db)
                }
                .flatMap { // Create or update my post filter
                    PostFilter(postID: post.id!, deviceID: post.deviceID, postFilterType: PostFilter.FilterType.myPost).create(on: req.db)
                }
                .map { Post.Output(id: post.id, deviceID: post.deviceID, text: post.text, numberOfComments: 0, createdAt: post.createdAt, updatedAt: post.updatedAt, channelID: channelID) }
        }
    }
}
