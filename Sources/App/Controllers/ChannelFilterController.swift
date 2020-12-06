import Fluent
import Vapor

struct ChannelFilterController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let channels = routes.grouped("channels")
        channels.get("filter", "myChannels", use: getMyChannels)
    }
    
    // MYCHANNELS
    func getMyChannels(_ req: Request)throws -> EventLoopFuture<Page<Channel>> {
        return try Channel.query(on: req.db)
            .filter(\.$deviceID == req.getAppHeaders().deviceID)
            .sort(\.$text)
            .paginate(for: req)
    }
}
