import Fluent
import Vapor

final class Recipe: Model, Content {
    static var schema: String = "recipies"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "prep_time")
    var prepTime: Int // seconds
    
    @OptionalField(key: "cook_time")
    var cookTime: Int? // seconds
    
    @Field(key: "servings")
    var servings: Int
    
    @Group(key: "nutrition")
    var nutritionFacts: Nutrition
    
    @Field(key: "instructions")
    var instructions: [String]
    
    @Children(for: \.$recipe)
    var ingredientSections: [IngredientSection]
}

final class Nutrition: Fields {
    @Field(key: "calories")
    var calories: Float
    
    @Field(key: "fat")
    var fat: Float // in grams
    
    @Field(key: "saturated_fat")
    var saturatedFat: Float // in grams
    
    @Field(key: "cholesterol")
    var cholesterol: Float // in mg
    
    @Field(key: "sodium")
    var sodium: Float // in mg
    
    @Field(key: "potassium")
    var potassium: Float //  im mg
    
    @Field(key: "carbs")
    var carbs: Float // in grams
    
    @Field(key: "sugars")
    var sugars: Float // in grams
    
    @Field(key: "added_sugars")
    var addedSugars: Float // in grams
    
    @Field(key: "protein")
    var protein: Float // in grams
}
