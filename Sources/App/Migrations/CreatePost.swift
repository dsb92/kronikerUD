import Fluent

struct CreatePost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts")
            .id()
            .field("device_id", .uuid, .required)
            .field("text", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts").delete()
    }
}

