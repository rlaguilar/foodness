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
    
    func newToken(withScope scope: UserToken.Scope, location: UserToken.Location, sourceTokenID: UUID?) -> UserToken {
        return UserToken(
            value: RandomURLPathValidCharacterGenerator.shared.next(length: 24),
            expireDate: scope.preferredExpirationDate(),
            scope: scope,
            location: location,
            userID: id!,
            sourceTokenID: sourceTokenID
        )
    }
}

private class RandomURLPathValidCharacterGenerator {
    static let shared = RandomURLPathValidCharacterGenerator()
    private let allowedChars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
    
    func next(length: Int) -> String {
        let characters = (0 ..< length)
            .map { _ in allowedChars[Int.random(in: 0 ..< allowedChars.count)] }
    
        return String(characters)
    }
}
