import Fluent

struct CreateBlockedDevice: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blocked_devices")
            .id()
            .field("device_id", .uuid, .required)
            .field("blocked_device_id", .uuid, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("blocked_devices").delete()
    }
}
