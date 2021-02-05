import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes
            .grouped("auth")
//            .grouped(UserBasicAuthenticator())
//            .grouped(User.guardMiddleware())
        
        
        auth.post("signup", use: signup)
//        auth.post("me", use: me)
        
//
//        comments.get(use: index)
//        comments.post(use: create)
//
//        comments.group(":commentID") { comment in
//            comment.delete(use: delete)
//        }
    }
    
    func signup(req: Request) throws -> EventLoopFuture<GetUser> {
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
    
    // TODO: Get this out of here
    func me(req: Request) throws -> GetUser {
        let user = try req.auth.require(User.self)
        return try GetUser(user: user)
    }
    
//    func index(req: Request) -> EventLoopFuture<[Comment]> {
//        return Comment.query(on: req.db).all()
//    }
//
//    func create(req: Request) throws -> EventLoopFuture<Comment> {
//        let comment = try req.content.decode(Comment.self)
//        return comment.save(on: req.db).map { comment }
//    }
//
//    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return Comment.find(req.parameters.get("commentID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
//    }
}

struct UserBasicAuthenticator: BasicAuthenticator {
    typealias User = App.User
    
    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        let user = User.query(on: request.db)
            .filter(\.$email == basic.username)
            .first()
            .unwrap(or: Abort(.unauthorized))
        
        return user.flatMapThrowing { user in
            if try Bcrypt.verify(basic.password, created: user.passwordHash) {
                request.auth.login(user)
            }
        }
    }
}
