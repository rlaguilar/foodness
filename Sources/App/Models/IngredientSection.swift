import Fluent
import Vapor

final class IngredientSection: Model, Content {
    static var schema: String = "ingredient_sections"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalField(key: "title")
    var title: String?
    
    @Parent(key: "recipe_id")
    var recipe: Recipe
    
    @Children(for: \.$ingredientSection)
    var measuredIngredients: [MeasuredIngredient]
}
