import Fluent

struct CreateIngredientSection: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(IngredientSection.schema)
            .id()
            .field("title", .string)
            .field("recipe_id", .uuid, .required, .references(Recipe.schema, "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(IngredientSection.schema).delete()
    }
}
