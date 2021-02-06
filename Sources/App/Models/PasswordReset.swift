import Fluent
import Vapor

struct TemporaryBecauseWeDoNotSendEmailPasswordReset: Content {
    let code: String
    
    static let invalid = TemporaryBecauseWeDoNotSendEmailPasswordReset(code: "Invalid")
}

extension TemporaryBecauseWeDoNotSendEmailPasswordReset {
    init(reset: PasswordReset) {
        code = reset.id!.uuidString
    }
}

final class PasswordReset: Model, Content {
    static var schema: String = "password_resets"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "expire_date")
    var expireDate: Date
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, email: String, expireDate: Date, userID: UUID) {
        self.id = id
        self.email = email
        self.expireDate = expireDate
        self.$user.id = userID
    }
}
