import Fluent

struct CreateUserToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserToken.schema)
            .id()
            .field("value", .string, .required)
            .field("expire_date", .datetime, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .field("source_token_id", .uuid, .references(UserToken.schema, "id", onDelete: .cascade))
            .field("scope_refresh_token", .bool, .required)
            .field("scope_access_resources", .bool, .required)
            .unique(on: "value")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(UserToken.schema).delete()
    }
}
