import Fluent
import Vapor

struct GetUserToken: Content {
    let value: String
    let expireDate: Date
    let scope: UserToken.Scope
    
    init(token: UserToken) {
        self.value = token.value
        self.expireDate = token.expireDate
        self.scope = token.scope
    }
}

final class UserToken: Model, Content, Authenticatable {
    static var schema: String = "tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "expire_date")
    var expireDate: Date
    
    @Group(key: "scope")
    var scope: Scope
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalParent(key: "source_token_id")
    var sourceToken: UserToken?
    
    init() {}
    
    init(id: UUID? = nil, value: String, expireDate: Date, scope: Scope, userID: UUID, sourceTokenID: UUID? = nil) {
        self.id = id
        self.value = value
        self.expireDate = expireDate
        self.scope = scope
        self.$user.id = userID
        self.$sourceToken.id = sourceTokenID
    }
    
    final class Scope: Fields {
        @Field(key: "refresh_token")
        var refreshToken: Bool
        
        @Field(key: "access_resources")
        var accessResources: Bool
        
        init() {}
        
        init(refreshToken: Bool, accessResources: Bool) {
            self.refreshToken = refreshToken
            self.accessResources = accessResources
        }
        
        func preferredExpirationDate() -> Date {
            if accessResources {
                return Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week
            }
            else if refreshToken {
                return Date.distantFuture
            }
            else {
                return Date.distantPast
            }
        }
    }
}
