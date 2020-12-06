import Fluent

struct DetailAddEnterChatforum: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("details")
            .field("enter_chatforum", .bool, .required, .sql(.default(false)))
            .update()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("details")
            .field("enter_chatforum", .string, .required, .sql(.default(false)))
            .delete()
    }
}
