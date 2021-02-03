import Fluent
import Vapor

final class Post: Model, Content {
    static var schema: String = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "body")
    var body: String
    
    @Parent(key: "recipe_id")
    var recipe: Recipe
    
    
}

final class Comment: Model, Content {
    static var schema: String = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "message")
    var message: String
}

