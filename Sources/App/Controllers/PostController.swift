import Fluent
import Vapor

struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        
        posts.get(use: index)
        posts.post(use: create)
        
        posts.group(":postID") { post in
            post.get(use: item)
            post.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[Post]> {
        return Post.query(on: req.db).all()
    }

    func item(req: Request) throws -> EventLoopFuture<GetPost> {
        guard let postIDStr = req.parameters.get("postID"),
              let postID = UUID(uuidString: postIDStr) else {
            throw Abort(.badRequest)
        }

        return Post.query(on: req.db)
            .filter(\.$id == postID)
            .with(\.$author)
            .with(\.$recipe, {
                $0.with(\.$ingredientSections) {
                    $0.with(\.$measuredIngredients) {
                        $0.with(\.$ingredient).with(\.$unit)
                    }
                }
            })
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing(GetPost.init(post:))
    }

    func create(req: Request) throws -> EventLoopFuture<Post> {
        let post = try req.content.decode(Post.self)
        return post.save(on: req.db).map { post }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Post.find(req.parameters.get("postID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
