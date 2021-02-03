import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: IngredientController())
    try app.register(collection: IngredientSectionController())
    try app.register(collection: MeasuredIngredientController())
    try app.register(collection: MeasureUnitController())
    try app.register(collection: RecipeController())
//    try app.register(collection: TodoController())
}
