import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get(use: index)
//        users.post(use: create)
        
        users.group(":username") { user in
            user.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<GetUser> {
        let newUserRequest = try req.content.decode(PutUser.self)
        
        return req.password.async.hash(newUserRequest.password).flatMap { hashedPassword in
            let user = User(
                username: newUserRequest.username,
                email: newUserRequest.email,
                passwordHash: hashedPassword,
                firstName: newUserRequest.firstName,
                lastName: newUserRequest.lastName,
                avatarURL: nil
            )
            
            return user.save(on: req.db).flatMapThrowing { try GetUser(user: user) }
        }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.find(req.parameters.get("username"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
