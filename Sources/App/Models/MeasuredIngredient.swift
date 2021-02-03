import Fluent
import Vapor

final class MeasuredIngredient: Model, Content {
    static var schema: String = "measured_ingredients"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "amount")
    var amount: Float
    
    @OptionalField(key: "details")
    var details: String?
    
    @Parent(key: "unit_id")
    var unit: MeasureUnit
    
    @Parent(key: "ingredient_section_id")
    var ingredientSection: IngredientSection
    
    @Parent(key: "ingredient_id")
    var ingredient: Ingredient
    
    init() {}
    
    init(id: UUID? = nil, amount: Float, details: String? = nil, unitID: UUID, ingredientSectionID: UUID, ingredientID: UUID) {
        self.id = id
        self.amount = amount
        self.details = details
        self.$unit.id = unitID
        self.$ingredientSection.id = ingredientSectionID
        self.$ingredient.id = ingredientID
    }
}
