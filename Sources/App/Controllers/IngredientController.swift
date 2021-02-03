import Fluent
import Vapor

struct IngredientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let ingredients = routes.grouped("ingredients")
        
        ingredients.get(use: index)
        ingredients.post(use: create)
        
        ingredients.group(":ingredientID") { ingredient in
            ingredient.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[Ingredient]> {
        return Ingredient.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<Ingredient> {
        let ingredient = try req.content.decode(Ingredient.self)
        return ingredient.save(on: req.db).map { ingredient }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Ingredient.find(req.parameters.get("ingredientID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
