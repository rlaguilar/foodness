import Fluent
import Vapor

struct MeasureUnitController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let units = routes.grouped("measure-units")
        
        units.get(use: index)
        units.post(use: create)
        
        units.group(":unitID") { unit in
            unit.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[MeasureUnit]> {
        return MeasureUnit.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<MeasureUnit> {
        let unit = try req.content.decode(MeasureUnit.self)
        return unit.save(on: req.db).map { unit }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return MeasureUnit.find(req.parameters.get("unitID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
