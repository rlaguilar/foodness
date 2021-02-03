import Fluent

struct CreateIngredient: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Ingredient.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Ingredient.schema).delete()
    }
}
