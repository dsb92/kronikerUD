import Fluent

struct CreatePushDevice: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_devices")
            .id()
            .field("push_token_id", .uuid, .required, .references("push_tokens", "id", onDelete: .cascade))
            .field("app_version", .string, .required)
            .field("app_platform", .string, .required)
            .field("app_badge_count", .int, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_devices").delete()
    }
}

