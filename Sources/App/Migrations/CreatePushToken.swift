import Fluent

struct CreatePushToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_tokens")
            .id()
            .field("token", .string, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("push_tokens").delete()
    }
}

