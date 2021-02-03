import Fluent
import Vapor

struct MeasuredIngredientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let measures = routes.grouped("measured-ingredients")
        
        measures.get(use: index)
        measures.post(use: create)
        
        measures.group(":measureID") { measure in
            measure.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[MeasuredIngredient]> {
        return MeasuredIngredient.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<MeasuredIngredient> {
        let measure = try req.content.decode(MeasuredIngredient.self)
        return measure.save(on: req.db).map { measure }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return MeasuredIngredient.find(req.parameters.get("measureID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
