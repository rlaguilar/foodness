import Fluent
import Vapor

final class Post: Model, Content {
    static var schema: String = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    @Field(key: "body")
    var body: String
    
    @Field(key: "rating_count")
    var ratingCount: Int
    
    @Field(key: "rating_sum")
    var ratingSum: Int
    
    @OptionalParent(key: "author_id")
    var author: User?
    
    @Parent(key: "recipe_id")
    var recipe: Recipe
    
    @Children(for: \.$post)
    var comments: [Comment]
}
