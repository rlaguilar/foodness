import Fluent
import Vapor

struct GetPost: Content {
    let id: UUID

    let createdAt: Date
    
    let updatedAt: Date
    
    let deletedAt: Date?

    let title: String
    
    let teaser: String
    
    let body: String
    
    let rating: Float
    
    let author: GetUser?
    
    let recipe: GetRecipe
    
    init(post: Post) throws {
        self.id = try post.requireID()
        
        guard let createdAt = post.createdAt,
              let updatedAt = post.updatedAt else {
            throw Abort(.internalServerError)
        }
        
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.deletedAt = post.deletedAt
        self.title = post.title
        self.teaser = post.teaser
        self.body = post.body
        self.rating = post.ratingCount > 0 ? Float(post.ratingSum) / Float(post.ratingCount) : 0
        self.author = post.author.map(GetUser.init(user:))
        self.recipe = try GetRecipe(recipe: post.recipe)
    }
}

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
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "teaser")
    var teaser: String
    
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
    
    init() {}
    
    init(id: UUID? = nil, title: String, teaser: String, body: String, ratingCount: Int, ratingSum: Int, authorID: UUID?, recipeID: UUID) {
        self.id = id
        self.title = title
        self.teaser = teaser
        self.body = body
        self.ratingCount = ratingCount
        self.ratingSum = ratingSum
        self.$author.id = authorID
        self.$recipe.id = recipeID
    }
}
