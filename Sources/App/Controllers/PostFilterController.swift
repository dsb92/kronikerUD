import Fluent
import Vapor

struct PostFilterController: RouteCollection, ApiController {
    typealias Model = PostFilter
    
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "postFilters")
        let posts = routes.grouped("posts")
        posts.get("filter", "myPosts", use: getMyPosts)
        posts.get("filter", "myComments", use: getMyComments)
        posts.get("filter", "myChannels", use: getMyChannels)
    }
    
    //MYPOSTS
    func getMyPosts(_ req: Request)throws -> EventLoopFuture<Page<Post>> {
        return try getUserPosts(req, of: .myPost)
    }
    
    // MYCOMMENTS
    func getMyComments(_ req: Request)throws -> EventLoopFuture<Page<Post>> {
        return try getUserPosts(req, of: .myComments)
    }
    
    // MYCHANNELS
    func getMyChannels(_ req: Request)throws -> EventLoopFuture<Page<Post>> {
        return try Post.query(on: req.db)
            .join(Channel.self, on: \Channel.$id == \Post.$channel.$id)
            .filter(Channel.self, \Channel.$deviceID == req.getAppHeaders().deviceID)
            .with(\.$channel)
            .paginate(for: req)
    }
    
    private func getUserPosts(_ req: Request, of type: PostFilter.FilterType)throws -> EventLoopFuture<Page<Post>> {
        return try Post.query(on: req.db)
            .join(PostFilter.self, on: \PostFilter.$postID == \Post.$id)
            .filter(PostFilter.self, \PostFilter.$deviceID == req.getAppHeaders().deviceID)
            .filter(PostFilter.self, \PostFilter.$postFilterType == type)
            .sort(\.$createdAt, .descending)
            .with(\.$channel)
            .paginate(for: req)
    }
}
