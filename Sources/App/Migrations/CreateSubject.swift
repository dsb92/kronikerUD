import Fluent

struct CreateSubject: Migration {
    // Prepares the database for storing Star models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subjects")
            .id()
            .field("parent_id", .uuid, .references("subjects", "id"))
            .field("text", .string)
            .field("iconURL", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subjects").delete()
    }
}
