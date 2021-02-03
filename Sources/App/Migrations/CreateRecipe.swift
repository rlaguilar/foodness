import Fluent

struct CreateRecipe: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Recipe.schema)
            .id()
            .field("name", .string, .required)
            .field("prep_time", .int, .required)
            .field("cook_time", .int)
            .field("servings", .int, .required)
            .field("instructions", .array(of: .string), .required)
            .field("nutrition_added_sugars", .float, .required)
            .field("nutrition_calories", .float, .required)
            .field("nutrition_carbs", .float, .required)
            .field("nutrition_cholesterol", .float, .required)
            .field("nutrition_fat", .float, .required)
            .field("nutrition_potassium", .float, .required)
            .field("nutrition_protein", .float, .required)
            .field("nutrition_saturated_fat", .float, .required)
            .field("nutrition_sodium", .float, .required)
            .field("nutrition_sugars", .float, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Recipe.schema).delete()
    }
}
