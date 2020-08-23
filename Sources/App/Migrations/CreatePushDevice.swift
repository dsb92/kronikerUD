import Fluent

struct CreatePushDevice: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_devices")
            .id()
            .field("push_token_id", .uuid, .references("push_tokens", "id"))
            .field("app_version", .string, .required)
            .field("app_platform", .string, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_devices").delete()
    }
}

