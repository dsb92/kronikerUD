import Vapor
import Fluent

struct HttpHeaders {
    var deviceID: UUID
    var version: String
    var platform: String
    var badgeCount: Int
}

extension Request {
    func getAppHeaders() throws -> HttpHeaders {
        let deviceID = try getDeviceUUID()
        let appVersion = try getAppVersion()
        let appPlatform = try getAppPlatform()
        let badgeCount = try getAppBadgeCount()
        return HttpHeaders(deviceID: deviceID, version: appVersion, platform: appPlatform, badgeCount: badgeCount)
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
    
    private func getAppBadgeCount() throws -> Int {
        guard let badgeCount = self.headers["badgeCount"].first else { return 0 }
        return Int(badgeCount) ?? 0
    }
}
