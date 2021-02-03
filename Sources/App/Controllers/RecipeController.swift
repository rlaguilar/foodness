import Fluent
import Vapor

struct RecipeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recipes = routes.grouped("recipes")
        
        recipes.get(use: index)
        recipes.post(use: create)
        
        recipes.group(":recipeID") { recipe in
            recipe.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[Recipe]> {
        return Recipe.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<Recipe> {
        let recipe = try req.content.decode(Recipe.self)
        return recipe.save(on: req.db).map { recipe }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Recipe.find(req.parameters.get("recipeID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
