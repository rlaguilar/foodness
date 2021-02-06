import Fluent

struct CreatePasswordReset: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(PasswordReset.schema)
            .id()
            .field("email", .string, .required)
            .field("expire_date", .datetime, .required)
            .field("user_id", .uuid, .required, .references(User.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(PasswordReset.schema).delete()
    }
}
