import Fluent
import Vapor

final class GetComment: Content {
    let id: UUID
    let createdAt: Date
    let updatedAt: Date
    let deletedAt: Date?
    let message: String
    let likes: Int
    let author: GetUser?
    let targetComment: GetComment?
    let replies: [GetComment]
    
    init(comment: Comment) throws {
        id = try comment.requireID()
        
        guard let createdAt = comment.createdAt,
              let updatedAt = comment.updatedAt else {
            throw Abort(.internalServerError)
        }
        
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        deletedAt = comment.deletedAt
        message = comment.message
        likes = comment.likes
        author = comment.author.map { GetUser(user: $0) }
        targetComment = try comment.targetComment.map { try GetComment(comment: $0) }
        replies = try comment.replies.map(GetComment.init(comment:))
    }
}


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
    
    @OptionalParent(key: "author_id")
    var author: User?
    
    @Parent(key: "post_id")
    var post: Post
    
    @OptionalParent(key: "target_comment_id")
    var targetComment: Comment?
    
    @Children(for: \.$targetComment)
    var replies: [Comment]
}
