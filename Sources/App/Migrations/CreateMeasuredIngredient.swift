import Fluent

struct CreateMeasuredIngredient: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(MeasuredIngredient.schema)
            .id()
            .field("amount", .float, .required)
            .field("details", .string)
            .field("unit_id", .uuid, .required, .references(MeasureUnit.schema, "id", onDelete: .cascade))
            .field("ingredient_section_id", .uuid, .required, .references(IngredientSection.schema, "id", onDelete: .cascade))
            .field("ingredient_id", .uuid, .required, .references(Ingredient.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(MeasuredIngredient.schema).delete()
    }
}
