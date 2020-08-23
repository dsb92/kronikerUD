import Vapor

final class SecretMiddleware: Middleware {
    
    let username: String
    let password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        // Basic auth OR bearer is OK.
        guard let _ = request.headers.bearerAuthorization else {
            guard let basicAuthorization = request.headers.basicAuthorization else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Missing authorization"))
            }
            
            guard basicAuthorization.username == username else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Wrong username"))
            }
            
            guard basicAuthorization.password == password else {
                return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Wrong password"))
            }
            
            return next.respond(to: request)
        }
        
        return next.respond(to: request)
    }
}
