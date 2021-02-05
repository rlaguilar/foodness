import Fluent
import Vapor

struct PutLogin: Content {
    let refreshToken: Bool?
}

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes
            .grouped("auth")

        auth.post("signup", use: signup)
        
        let authenticated = auth
            .grouped(UserBasicAuthenticator())
            .grouped(UserBearerAuthenticator())
            .grouped(AuthUser.guardMiddleware())
        
        authenticated.post("login", use: login)
        authenticated.post("logout", use: logout)
    }
    
    func login(req: Request) throws -> EventLoopFuture<GetUserToken> {
        let authUser = try req.auth.require(AuthUser.self)
        
        let loginParams = req.content.contentType != nil ? try req.content.decode(PutLogin.self) : nil
        
        let tokenScope = UserToken.Scope(refreshToken: loginParams?.refreshToken == true, accessResources: loginParams?.refreshToken != true)
        let newToken = authUser.user.newToken(withScope: tokenScope)
        return newToken.save(on: req.db).map { GetUserToken(token: newToken) }
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
            
            return user.save(on: req.db).map { GetUser(user: user) }
        }
    }
    
    func logout(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authUser = try req.auth.require(AuthUser.self)
        
        guard let token = authUser.token else {
            throw Abort(.badRequest)
        }
        
        guard token.sourceToken == nil else {
            throw Abort(.badRequest)
        }
        
        return token.delete(on: req.db).transform(to: .ok)
    }
    
    // TODO: Get this out of here
//    func me(req: Request) throws -> GetUser {
//        let user = try req.auth.require(User.self)
//        return try GetUser(user: user)
//    }
    
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
    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        let user = User.query(on: request.db)
            .filter(\.$email == basic.username)
            .first()
            .unwrap(or: Abort(.notFound))
        
        return user.flatMapThrowing { user in
            if try Bcrypt.verify(basic.password, created: user.passwordHash) {
                request.auth.login(AuthUser(user: user, token: nil))
            }
        }
    }
}

struct UserBearerAuthenticator: BearerAuthenticator {
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        let token = UserToken.query(on: request.db)
            .filter(\.$value == bearer.token)
            .filter(\.$expireDate > Date())
            .with(\.$user)
            .first()
            .unwrap(or: Abort(.notFound))
        
        return token.map { loadedToken in
            request.auth.login(AuthUser(user: loadedToken.user, token: loadedToken))
        }
    }
}
