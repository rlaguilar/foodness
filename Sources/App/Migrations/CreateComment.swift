import Fluent

struct CreateComment: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Comment.schema)
            .id()
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .field("message", .string, .required)
            .field("likes", .int, .required)
            .field("author_id", .uuid, .references(User.schema, "id", onDelete: .setNull))
            .field("post_id", .uuid, .required, .references(Post.schema, "id", onDelete: .cascade))
            .field("target_comment_id", .uuid, .references(Comment.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Comment.schema).delete()
    }
}
