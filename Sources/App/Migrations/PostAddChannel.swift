import Fluent

struct PostAddChannel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts")
            .field("channel_id", .uuid, .references("channels", "id", onDelete: .cascade))
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts")
            .field("channel_id", .uuid, .references("channels", "id", onDelete: .cascade))
            .delete()
    }
}
