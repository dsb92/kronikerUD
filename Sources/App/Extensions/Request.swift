import Vapor
import Fluent

struct HttpHeaders {
    var deviceID: UUID
    var version: String
    var platform: String
}

extension Request {
    func getAppHeaders() throws -> HttpHeaders {
        let deviceID = try getDeviceUUID()
        let appVersion = try getAppVersion()
        let appPlatform = try getAppPlatform()
        return HttpHeaders(deviceID: deviceID, version: appVersion, platform: appPlatform)
    }
    
    private func getDeviceUUID() throws -> UUID {
        guard let deviceIDString = self.headers["deviceID"].first, let deviceID = UUID(uuidString: deviceIDString) else { throw Abort.init(.badRequest, reason: "Missing 'deviceID' in header") }
        return deviceID
    }
    
    private func getAppVersion() throws -> String {
        guard let version = self.headers["version"].first else { throw Abort.init(.badRequest, reason: "Missing 'version' in header") }
        return version
    }
    
    private func getAppPlatform() throws -> String {
        guard let platform = self.headers["platform"].first else { throw Abort.init(.badRequest, reason: "Missing 'platform' in header") }
        return platform
    }
}
