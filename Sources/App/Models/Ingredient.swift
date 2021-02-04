import Fluent
import Vapor

final class Ingredient: Model, Content {
    static var schema: String = "ingredients"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$ingredient)
    var measuredIngredients: [MeasuredIngredient]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
