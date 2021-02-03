import Fluent
import Vapor

struct CommentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let comments = routes.grouped("comments")
        
        comments.get(use: index)
        comments.post(use: create)
        
        comments.group(":commentID") { comment in
            comment.delete(use: delete)
        }
    }
    
    func index(req: Request) -> EventLoopFuture<[Comment]> {
        return Comment.query(on: req.db).all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<Comment> {
        let comment = try req.content.decode(Comment.self)
        return comment.save(on: req.db).map { comment }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Comment.find(req.parameters.get("commentID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
