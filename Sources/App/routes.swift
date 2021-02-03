import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "Welcome to Foodness API! Start by using any of the endpoints:\n\(app.routes.all.description)"
    }

    try app.register(collection: IngredientController())
    try app.register(collection: IngredientSectionController())
    try app.register(collection: MeasuredIngredientController())
    try app.register(collection: MeasureUnitController())
    try app.register(collection: RecipeController())
    try app.register(collection: UserController())
    try app.register(collection: CommentController())
    try app.register(collection: PostController())
}
