import Fluent
import Vapor

struct GetUserToken: Content {
    let value: String
    let createdAt: Date?
    let lastAccessDate: Date?
    let expireDate: Date
    let scope: UserToken.Scope
    let location: UserToken.Location
    
    init(token: UserToken) {
        self.value = token.value
        self.createdAt = token.createdAt
        self.lastAccessDate = token.lastAccessDate
        self.expireDate = token.expireDate
        self.scope = token.scope
        self.location = token.location
    }
}

final class UserToken: Model, Content, Authenticatable {
    static var schema: String = "tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @OptionalField(key: "last_access_date")
    var lastAccessDate: Date?
    
    @Field(key: "expire_date")
    var expireDate: Date
    
    @Group(key: "location")
    var location: Location
    
    @Group(key: "scope")
    var scope: Scope
    
    @Parent(key: "user_id")
    var user: User
    
    @OptionalParent(key: "source_token_id")
    var sourceToken: UserToken?
    
    init() {}
    
    init(id: UUID? = nil, value: String, lastAccessDate: Date?, expireDate: Date, scope: Scope, location: Location, userID: UUID, sourceTokenID: UUID? = nil) {
        self.id = id
        self.value = value
        self.lastAccessDate = lastAccessDate
        self.expireDate = expireDate
        self.scope = scope
        self.location = location
        self.$user.id = userID
        self.$sourceToken.id = sourceTokenID
    }
    
    final class Location: Fields {
        @OptionalField(key: "ip")
        var ip: String?
        
        @OptionalField(key: "country_name")
        var countryName: String?
        
        @OptionalField(key: "country_code")
        var countryCode: String?

        @OptionalField(key: "region_name")
        var regionName: String?
        
        @OptionalField(key: "region_code")
        var regionCode: String?
        
        @OptionalField(key: "city")
        var city: String?
        
        @OptionalField(key: "latitude")
        var latitude: Double?
        
        @OptionalField(key: "longitude")
        var longitude: Double?
        
//        private enum CodingKeys : String, CodingKey {
//            case ip, countryName = "country_name", countryCode = "country_code", regionName = "region_name", regionCode = "region_code", city, latitude
//        }
        
        init() {}
        
        init(
            ip: String?,
            countryName: String?,
            countryCode: String?,
            regionName: String?,
            regionCode: String?,
            city: String?,
            latitude: Double?,
            longitude: Double?
        ) {
            self.ip = ip
            self.countryName = countryName
            self.countryCode = countryCode
            self.regionName = regionName
            self.regionCode = regionCode
            self.city = city
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    final class Scope: Fields {
        @Field(key: "refresh_token")
        var refreshToken: Bool
        
        @Field(key: "access_resources")
        var accessResources: Bool
        
        @Field(key: "sudo_access")
        var sudoAccess: Bool
        
        init() {}
        
        init(refreshToken: Bool, accessResources: Bool, sudoAccess: Bool) {
            self.refreshToken = refreshToken
            self.accessResources = accessResources
            self.sudoAccess = sudoAccess
        }
        
        func preferredExpirationDate() -> Date {
            if sudoAccess {
                return Date().addingTimeInterval(1 * 60 * 60) // 1 hour
            }
            else if accessResources {
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
