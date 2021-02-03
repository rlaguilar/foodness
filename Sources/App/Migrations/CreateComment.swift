import Fluent

struct CreateComment: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Comment.schema)
            .id()
            .field("created_at", .string)
            .field("updated_at", .string)
            .field("deleted_at", .string)
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
