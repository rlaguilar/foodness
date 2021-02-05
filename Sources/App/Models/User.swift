import Fluent
import Vapor

struct GetUser: Content {
    let username: String
    
    let email: String
    
    let firstName: String
    
    let lastName: String
    
    let avatarURL: String?
    
    init(user: User) {
        self.username = user.username
        self.email = user.email
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.avatarURL = user.avatarURL
    }
}

struct PutUser: Content {
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let password: String
}

struct AuthUser: Content, Authenticatable {
    let user: User
    let token: UserToken?
}

final class User: Model, Content {
    static var schema: String = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @OptionalField(key: "avatar_url")
    var avatarURL: String?
    
    @Children(for: \.$user)
    var tokens: [UserToken]
    
    init() {}
    
    init(id: UUID? = nil, username: String, email: String, passwordHash: String, firstName: String, lastName: String, avatarURL: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
    }
    
    func newToken(withScope scope: UserToken.Scope) -> UserToken {
        return UserToken(
            value: [UInt8].random(count: 16).base64,
            expireDate: scope.preferredExpirationDate(),
            scope: scope,
            userID: id!
        )
    }
}
