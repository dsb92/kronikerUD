import Fluent

struct CreateAllowedDevice: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("allowed_devices")
            .id()
            .field("version", .string, .required)
            .field("platform", .string, .required)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("allowed_devices").delete()
    }
}
