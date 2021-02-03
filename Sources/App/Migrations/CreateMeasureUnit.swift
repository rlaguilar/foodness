import Fluent

struct CreateMeasureUnit: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(MeasureUnit.schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(MeasureUnit.schema).delete()
    }
}
