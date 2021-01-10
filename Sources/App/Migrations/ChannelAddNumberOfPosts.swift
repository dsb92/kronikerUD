import Fluent

struct ChannelAddNumberOfPosts: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("channels")
            .field("numberOfPosts", .int, .required, .sql(.default(0)))
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("channels")
            .field("numberOfComments", .int, .required, .sql(.default(0)))
            .delete()
    }
}
