import Vapor
import Fluent

final class VersionMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        do {
            let appHeaders = try request.getAppHeaders()
            let version = appHeaders.version
            let platform = appHeaders.platform
            
            return AllowedDevice.query(on: request.db).group(.or) { group in
                group.filter(\AllowedDevice.$platform == platform).filter(\AllowedDevice.$version == version)
            }.first().flatMap { allowedDevice in
                guard let allowedDevice = allowedDevice else {
                    return next.respond(to: request)
                }
                
                guard let appVersion = Double(version) else {
                    return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Version is in unknown format."))
                }
                
                guard let apiVersion = Double(allowedDevice.version) else {
                    return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Api version is in unknown format."))
                }
                
                if allowedDevice.platform == platform && apiVersion > appVersion {
                    return request.eventLoop.makeFailedFuture(Abort(.conflict, reason: "Platform \(platform) has a newer version"))
                }
                
                return next.respond(to: request)
            }
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}
