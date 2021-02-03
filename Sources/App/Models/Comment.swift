import Fluent
import Vapor

final class Comment: Model, Content {
    static var schema: String = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    @Field(key: "message")
    var message: String
    
    @Field(key: "likes")
    var likes: Int
    
    @Parent(key: "post_id")
    var post: Post
    
    @OptionalParent(key: "target_comment_id")
    var targetComment: Comment?
    
    @Children(for: \.$targetComment)
    var replies: [Comment]
}
