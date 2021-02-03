import Fluent

struct CreatePost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Post.schema)
            .id()
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .field("body", .string, .required)
            .field("rating_count", .int, .required)
            .field("rating_sum", .int, .required)
            .field("author_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("recipe_id", .uuid, .references(Recipe.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Post.schema).delete()
    }
}
