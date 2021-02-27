import Fluent

struct PushDeviceAddBadgeCount: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_devices")
            .field("app_badge_count", .int, .required, .sql(.default(0)))
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_devices").delete()
    }
}

