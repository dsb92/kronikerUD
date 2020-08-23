import Fluent

struct CreateNotification: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notifications")
            .id()
            .field("token", .string, .required)
            .field("title", .string, .required)
            .field("body", .string, .required)
            .field("data", .json)
            .field("category", .string)
            .field("silent", .bool)
            .field("mutable_content", .bool)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notifications").delete()
    }
}

