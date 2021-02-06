import Fluent
import Vapor

struct PutLogin: Content {
    let accessResources: Bool?
    let sudoAccess: Bool?
}

struct PutForgotPassword: Content {
    let email: String
}

struct PutResetPassword: Content {
    let email: String
    let password: String
}

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes
            .grouped("auth")

        auth.post("signup", use: signup)
        auth.post("forgot", use: forgotPassword)
        auth.post("reset", ":resetID", use: resetPassword)
        
        auth.grouped(UserBasicAuthenticator())
            .grouped(AuthUser.guardMiddleware())
            .post("login", use: login)
        
        let tokens = auth.grouped(UserBearerAuthenticator(requiresSudoAccessScope: true))
            .grouped(AuthUser.guardMiddleware())
            .grouped("tokens")
        
        tokens.get(use: listTokens)
        tokens.delete(":token", use: revokeToken)
        
        let authenticated = auth
            .grouped(UserBearerAuthenticator(requiresRefreshTokenScope: true))
            .grouped(AuthUser.guardMiddleware())
        
        authenticated.post("refresh", use: refreshToken)
        authenticated.post("logout", use: logout)
    }
    
    func listTokens(req: Request) throws -> EventLoopFuture<[GetUserToken]> {
        let authUser = try req.auth.require(AuthUser.self)
        return UserToken.query(on: req.db)
            .filter(\.$user.$id == authUser.user.id! )
            .filter(\.$expireDate > Date())
            .all()
            .mapEach(GetUserToken.init(token:))
    }
    
    func revokeToken(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authUser = try req.auth.require(AuthUser.self)
        let token = try req.parameters.require("token")
        
        return UserToken.query(on: req.db)
            .filter(\.$value == token)
            .first()
            .unwrap(or: Abort(.notFound))
            .guard({ $0.$user.id == authUser.user.id }, else: Abort(.unauthorized))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
    func login(req: Request) throws -> EventLoopFuture<GetUserToken> {
        let authUser = try req.auth.require(AuthUser.self)
        
        let loginParams = req.content.contentType != nil ? try req.content.decode(PutLogin.self) : nil
        
        let tokenScope = UserToken.Scope(
            refreshToken: true,
            accessResources: loginParams?.accessResources == true,
            sudoAccess: loginParams?.sudoAccess == true
        )
        
        return location(req: req)
            .recover { _ in UserToken.Location() }
            .map { authUser.user.newToken(withScope: tokenScope, location: $0, sourceTokenID: nil) }
            .flatMap { newToken in
                newToken.save(on: req.db).map { GetUserToken(token: newToken) }
            }
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
    
    func refreshToken(req: Request) throws -> EventLoopFuture<GetUserToken> {
        let authUser = try req.auth.require(AuthUser.self)
        
        guard let token = authUser.token else {
            throw Abort(.badRequest)
        }
        
        func scope(from scope: UserToken.Scope) -> UserToken.Scope {
            let refreshToken = scope.accessResources ? scope.refreshToken : false
            
            return UserToken.Scope(
                refreshToken: refreshToken,
                accessResources: true,
                // we can only get sudo-access tokens via the login endpoint by entering username and password
                sudoAccess: false
            )
        }
        
        token.lastAccessDate = Date()
        
        return location(req: req)
            .recover { _ in UserToken.Location() }
            .map { authUser.user.newToken(withScope: scope(from: token.scope), location: $0, sourceTokenID: token.id) }
            .flatMap { newToken in
                EventLoopFuture.andAllSucceed(
                    [newToken.save(on: req.db), token.save(on: req.db)],
                    on: req.eventLoop
                )
                .map { GetUserToken(token: newToken) }
            }
    }
    
    func logout(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let authUser = try req.auth.require(AuthUser.self)
        
        guard let token = authUser.token else {
            throw Abort(.badRequest)
        }
        
        return token.delete(on: req.db).transform(to: .ok)
    }
    
    func forgotPassword(req: Request) throws -> EventLoopFuture<TemporaryBecauseWeDoNotSendEmailPasswordReset> {
        let forgotPassword = try req.content.decode(PutForgotPassword.self)
        
        let errorWhenUserDoesNotExist = Abort.init(.notFound, identifier: "forgot password for not existing user")
        let userQuery = User.query(on: req.db).filter(\.$email == forgotPassword.email).first().unwrap(or: errorWhenUserDoesNotExist)
        
        return userQuery.flatMap { user in
            let passwordReset = PasswordReset(
                email: forgotPassword.email,
                expireDate: Date().addingTimeInterval(30 * 60), // 30 mins
                userID: user.id!
            )
            
            return passwordReset.save(on: req.db).map { TemporaryBecauseWeDoNotSendEmailPasswordReset(reset: passwordReset) }
        }
        .flatMapErrorThrowing { error -> TemporaryBecauseWeDoNotSendEmailPasswordReset in
            guard let abort = error as? Abort, abort.identifier == errorWhenUserDoesNotExist.identifier else {
                throw error
            }
            
            return .invalid
        }
    }

    func resetPassword(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let resetIDStr = req.parameters.get("resetID"),
              let resetID = UUID(uuidString: resetIDStr) else {
            throw Abort(.badRequest)
        }

        let resetPasswordData = try req.content.decode(PutResetPassword.self)
        
        return PasswordReset.query(on: req.db)
            .filter(\.$id == resetID)
            .with(\.$user) {
                $0.with(\.$tokens)
            }
            .first()
            .unwrap(or: Abort(.notFound))
            .guard({ $0.user.email == resetPasswordData.email }, else: Abort(.badRequest))
            .guard({ $0.expireDate > Date() }, else: Abort(.gone, reason: "The reset password expiration date is due. Please try reseting your password again."))
            .flatMap { reset -> EventLoopFuture<Void> in
                return req.password.async.hash(resetPasswordData.password).flatMap { hashedPassword in
                    let user = reset.user
                    user.passwordHash = hashedPassword
                    return user.save(on: req.db).flatMap {
                        EventLoopFuture.andAllComplete(user.tokens.map { $0.delete(on: req.db) }, on: req.eventLoop)
                    }
                }
            }
            .transform(to: .ok)
    }
    
    private func location(req: Request) -> EventLoopFuture<UserToken.Location> {
        guard let ipAddress = req.headers.forwarded.first?.for else {
            return req.eventLoop.makeSucceededFuture(UserToken.Location())
        }
        
        let ipstackURL: URI = "http://api.ipstack.com/\(ipAddress)?access_key=5291d83e523087ebb798020630838ea6"
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return req.client.get(ipstackURL).flatMapThrowing { try $0.content.decode(UserToken.Location.self, using: jsonDecoder) }
    }
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
    let requiresResourcesAccessScope: Bool
    let requiresRefreshTokenScope: Bool
    let requiresSudoAccessScope: Bool
    
    init(requiresResourcesAccessScope: Bool = false, requiresRefreshTokenScope: Bool = false, requiresSudoAccessScope: Bool = false) {
        self.requiresResourcesAccessScope = requiresResourcesAccessScope
        self.requiresRefreshTokenScope = requiresRefreshTokenScope
        self.requiresSudoAccessScope = requiresSudoAccessScope
    }
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        let token = UserToken.query(on: request.db)
            .filter(\.$value == bearer.token)
            .filter(\.$expireDate > Date())
            .with(\.$user)
            .first()
            .unwrap(or: Abort(.unauthorized))
        
        return token.map { loadedToken in
            guard !requiresResourcesAccessScope || loadedToken.scope.accessResources else {
                return
            }
            
            guard !requiresRefreshTokenScope || loadedToken.scope.refreshToken else {
                return
            }
            
            guard !requiresSudoAccessScope || loadedToken.scope.sudoAccess else {
                return
            }
            
            request.auth.login(AuthUser(user: loadedToken.user, token: loadedToken))
        }
    }
}
