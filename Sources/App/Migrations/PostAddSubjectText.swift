import Fluent

struct PostAddSubjectText: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts")
            .field("subject_text", .string)
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("posts")
            .field("subject_text", .string)
            .delete()
    }
}

