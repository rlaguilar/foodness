import Fluent
import Vapor

struct SeedData01: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return fakeUser.save(on: database)
            .flatMap {
                fakeRecipe.save(on: database)
            }
            .flatMap {
                EventLoopFuture.andAllComplete([
                        fakePost.save(on: database),
                        ml.save(on: database),
                        g.save(on: database)
                    ],
                    on: database.context.eventLoop
                )
            }
            .flatMap {
                EventLoopFuture.andAllComplete([
                    grahamCrackersIngredient.save(on: database),
                    unsaltedButterIngredient.save(on: database),
                    marshmallowsIngredient.save(on: database),
                    cheeseIngredient.save(on: database),
                    creamIngredient.save(on: database),
                    section1.save(on: database),
                    section2.save(on: database)
                    ],
                    on: database.context.eventLoop
                )
            }
            .flatMap {
                EventLoopFuture.andAllComplete(
                    (crustIngredients + cakeIngredients).map { $0.save(on: database) },
                    on: database.context.eventLoop
                )
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return EventLoopFuture.andAllComplete(
            (crustIngredients + cakeIngredients).map { $0.delete(on: database) },
            on: database.context.eventLoop
        )
        .flatMap {
            EventLoopFuture.andAllComplete([
                fakeRecipe.delete(on: database),
                grahamCrackersIngredient.delete(on: database),
                unsaltedButterIngredient.delete(on: database),
                marshmallowsIngredient.delete(on: database),
                cheeseIngredient.delete(on: database),
                creamIngredient.delete(on: database),
                section1.delete(on: database),
                section2.delete(on: database)
                ],
                on: database.context.eventLoop
            )
        }
        .flatMap {
            EventLoopFuture.andAllComplete([
                    fakePost.delete(on: database),
                    fakeUser.delete(on: database),
                    ml.delete(on: database),
                    g.delete(on: database)
                ],
                on: database.context.eventLoop
            )
        }
    }
}

private let ml = MeasureUnit(id: UUID(), name: "ml")
private let g = MeasureUnit(id: UUID(), name: "g")

private let fakeUser = User(
    id: UUID(),
    username: "rlaguilar",
    email: "rlac1990@gmail.com",
    passwordHash: try! Bcrypt.hash("qwerty"),
    firstName: "Reynaldo",
    lastName: "Aguilar",
    avatarURL: nil
)

private let fakeRecipe = Recipe(
    id: UUID(),
    name: "Strawberry Cream Cheesecake",
    prepTime: 900,
    cookTime: 800,
    servings: 4,
    nutritionFacts: Nutrition(
        calories: 219.9,
        fat: 10.7,
        saturatedFat: 2.2,
        cholesterol: 37.4,
        sodium: 120.3,
        potassium: 32.8,
        carbs: 22.3,
        sugars: 8.4,
        addedSugars: 8,
        protein: 7.9
    ), instructions: [
        "To prepare crust add graham crackers to a food processor and process until you reach fine crumbs. Add melted butter and pulse 3-4 times to coat crumbs with butter.",
        "Pour mixture into a 20cm (8”) tart tin. Use the back of a spoon to firmly press the mixture out across the bottom and sides of the tart tin. Chill for 30 min.",
        "Begin by adding the marshmallows and melted butter into a microwave safe bowl. Microwave for 30 seconds and mix to combine. Set aside.",
        "Next, add the gelatine and water to a small mixing bowl and mix to combine. Microwave for 30 seconds.",
        "Add the cream cheese to the marshmallow mixture and use a hand mixer or stand mixer fitted with a paddle attachment to mix until smooth.",
        "Add the warm cream and melted gelatin mixture and mix until well combined.",
        "Add 1/3 of the mixture to a mixing bowl, add purple food gel and mix until well combined. Colour 1/3 of the mixture blue. Split the remaining mixture into two mixing bowls, colour one pink and leave the other white.",
        "Pour half the purple cheesecake mixture into the chill tart crust. Add half the blue and then add the remaining purple and blue in the tart tin. Use a spoon to drizzle some pink cheesecake on top. Use a skewer or the end of a spoon to swirl the pink. Add some small dots of the plain cheesecake mixture to create stars and then sprinkle some more starts on top before chilling for 2 hours.",
        "Slice with a knife to serve."
    ])

private let grahamCrackersIngredient = Ingredient(id: UUID(), name: "graham crackers")
private let unsaltedButterIngredient = Ingredient(id: UUID(), name: "unsalted butter")
private let marshmallowsIngredient = Ingredient(id: UUID(), name: "marshmallows")
private let cheeseIngredient = Ingredient(id: UUID(), name: "Philadelphia cream cheese")
private let creamIngredient = Ingredient(id: UUID(), name: "thickened/whipping cream")

private let section1 = IngredientSection(id: UUID(), title: "For the crust", recipeID: fakeRecipe.id!)
private let section2 = IngredientSection(id: UUID(), title: "For the cheesecake", recipeID: fakeRecipe.id!)

private let crustIngredients: [MeasuredIngredient] = [
    MeasuredIngredient(id: UUID(), amount: 400, details: nil, unitID: g.id!, ingredientSectionID: section1.id!, ingredientID: grahamCrackersIngredient.id!),
    MeasuredIngredient(id: UUID(), amount: 150, details: "melted", unitID: g.id!, ingredientSectionID: section1.id!, ingredientID: unsaltedButterIngredient.id!)
]

private let cakeIngredients: [MeasuredIngredient] = [
    MeasuredIngredient(id: UUID(), amount: 300, details: nil, unitID: g.id!, ingredientSectionID: section2.id!, ingredientID: marshmallowsIngredient.id!),
    MeasuredIngredient(id: UUID(), amount: 175, details: "melted", unitID: g.id!, ingredientSectionID: section2.id!, ingredientID: unsaltedButterIngredient.id!),
    MeasuredIngredient(id: UUID(), amount: 500, details: "softened", unitID: g.id!, ingredientSectionID: section2.id!, ingredientID: cheeseIngredient.id!),
    MeasuredIngredient(id: UUID(), amount: 250, details: "warm", unitID: ml.id!, ingredientSectionID: section2.id!, ingredientID: creamIngredient.id!)
]

private let fakePost = Post(
    id: UUID(),
    title: "Mighty Super Cheesecake",
    teaser: "Look no further for a creamy and ultra smooth classic cheesecake recipe! no one can deny its simple decadence.",
    body: "One thing I learned living in the Canarsie section of Brooklyn, NY was how to cook a good Italian meal. Here is a recipe I created after having this dish in a restaurant. Enjoy!",
    ratingCount: 10,
    ratingSum: 44,
    authorID: fakeUser.id!,
    recipeID: fakeRecipe.id!
)

