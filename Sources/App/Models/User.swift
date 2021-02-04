import Fluent
import Vapor

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
}
