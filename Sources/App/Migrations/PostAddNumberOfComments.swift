import Fluent

struct PostAddNumberOfComments: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts")
            .field("numberOfComments", .int, .required, .sql(.default(0)))
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("numberOfComments")
            .field("numberOfComments", .int, .required, .sql(.default(0)))
            .delete()
    }
}
