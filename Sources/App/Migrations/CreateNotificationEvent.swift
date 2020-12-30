import Fluent

struct CreateNotificationEvent: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notification_events")
            .id()
            .field("push_token_id", .uuid, .required, .references("push_tokens", "id", onDelete: .cascade))
            .field("event_id", .uuid, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("notification_events").delete()
    }
}

