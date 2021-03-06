import Fluent
import Vapor

final class MeasureUnit: Model, Content {
    static var schema: String = "measure_units"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$unit)
    var measuredIngredients: [MeasuredIngredient]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
