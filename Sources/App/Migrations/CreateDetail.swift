import Fluent

struct CreateDetail: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("details")
            .id()
            .field("subject_id", .uuid, .references("subjects", "id"))
            .field("html_text", .string)
            .field("button_link_url", .string)
            .field("swipeable_texts", .array(of: .string))
            .field("video_link_urls", .array(of: .json))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("details").delete()
    }
}
