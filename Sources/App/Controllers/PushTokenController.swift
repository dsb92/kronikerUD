import Vapor
import Fluent

struct PushTokenController: RouteCollection, ApiController {
    typealias Model = PushToken
    func boot(routes: RoutesBuilder) throws {
        setup(routes: routes, on: "pushTokens")
    }
    
    func create(_ req: Request) throws -> EventLoopFuture<PushToken._Output> {
        let appHeaders = try req.getAppHeaders()
        let input = try req.content.decode(PushToken.Input.self)
        let pushToken = PushToken(token: input.token)
        return pushToken.save(on: req.db).flatMap {
            return PushDevice.find(appHeaders.deviceID, on: req.db)
            .flatMap { existing in
                if existing != nil {
                    existing!.appPlatform = appHeaders.platform
                    existing!.appVersion = appHeaders.version
                    existing!.$pushToken.id = pushToken.id!
                    return existing!.save(on: req.db)
                }
                let newPushDevice = PushDevice(id: appHeaders.deviceID, appVersion: appHeaders.version, appPlatform: appHeaders.platform, pushTokenID: pushToken.id!)
                return newPushDevice.create(on: req.db)
            }
            .map {
                PushToken.Output(id: pushToken.id!, token: pushToken.token)
            }
        }
    }
}
