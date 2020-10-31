import Fluent

struct CreatePostFilter: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        var enumBuilder = database.enum(PostFilter.FilterType.name.description)
        for option in PostFilter.FilterType.allCases {
            enumBuilder = enumBuilder.case(option.rawValue)
        }
        return enumBuilder.create()
            .flatMap { enumType in
                database.schema(PostFilter.schema)
                    .id()
                    .field("post_id", .uuid, .required)
                    .field("device_id", .uuid, .required)
                    .field(.postFilterType, enumType, .required)
                    .create()
            }
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(PostFilter.schema).delete().flatMap {
            database.enum(PostFilter.FilterType.name.description).delete()
        }
    }
}

