import Fluent

struct CreateSubject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subjects")
            .id()
            .field("parent_id", .uuid, .required, .references("subjects", "id", onDelete: .cascade))
            .field("text", .string, .required)
            .field("iconURL", .string, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subjects").delete()
    }
}

