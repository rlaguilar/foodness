import Fluent
import Vapor

struct IngredientSectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sections = routes.grouped("ingredient-sections")
        
        sections.get(use: index)
        sections.post(use: create)
        
        sections.group(":sectionID") { section in
            section.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[IngredientSection]> {
        return IngredientSection.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<IngredientSection> {
        let section = try req.content.decode(IngredientSection.self)
        return section.save(on: req.db).map { section }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return IngredientSection.find(req.parameters.get("sectionID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
