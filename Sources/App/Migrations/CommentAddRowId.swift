import Fluent

struct CommentAddRowId: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("comments")
            .field("row_id", .int, .required, .sql(.default(0)))
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("comments")
            .field("row_id", .int, .required, .sql(.default(0)))
            .delete()
    }
}
