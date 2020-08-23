import Fluent

struct CreateChannel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("channels")
            .id()
            .field("device_id", .uuid, .required)
            .field("text", .string, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts").delete()
    }
}

