import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get(use: index)
        
        users.grouped(UserBearerAuthenticator(requiresResourcesAccessScope: true, requiresRefreshTokenScope: false))
            .grouped(AuthUser.guardMiddleware())
            .get("me", use: me)
        
        users.group(":username") { user in
            user.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func me(req: Request) throws -> GetUser {
        let authUser = try req.auth.require(AuthUser.self)
        return GetUser(user: authUser.user)
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.find(req.parameters.get("username"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
