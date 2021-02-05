import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "reynaldoaguilar",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "foodness"
    ), as: .psql)

    
    app.migrations.add(CreateRecipe())
    app.migrations.add(CreateIngredient())
    app.migrations.add(CreateMeasureUnit())
    app.migrations.add(CreateIngredientSection())
    app.migrations.add(CreateMeasuredIngredient())
    app.migrations.add(CreateUser())
    app.migrations.add(CreatePost())
    app.migrations.add(CreateComment())
    app.migrations.add(CreateUserToken())
    app.migrations.add(SeedData01())
    // register routes
    try routes(app)
}
