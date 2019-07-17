import Vapor

struct MessagesController: RouteCollection {
  
  func boot(router: Router) throws {
    let messagesRoute = router.grouped("api", "messages")
    
    messagesRoute.post(Message.self, use: createHandler)
    messagesRoute.get(use: getAllHandler)
    messagesRoute.get(Message.parameter, use: getHandler)
  }
  
  func createHandler(_ req: Request, message: Message) throws -> Future<Message> {
    return message.save(on: req)
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[Message]> {
    return Message.query(on: req).all()
  }
  
  func getHandler(_ req: Request) throws -> Future<Message> {
    return try req.parameters.next(Message.self)
  }
}
