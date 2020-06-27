import Fluent

struct SubjectAddBackgroundColor: Migration {
    // Prepares the database for storing Star models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subjects")
            .field("backgroundColor", .string, .required)
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("subjects")
            .field("backgroundColor", .string, .required)
            .update()
    }
}
