import Vapor

struct MessagesController: RouteCollection {
  
  func boot(router: Router) throws {
    let messagesRoute = router.grouped("api", "messages")
    
//    messagesRoute.post(Message.self, use: createHandler)
//    messagesRoute.get(use: getAllHandler)
//    messagesRoute.get(Message.parameter, use: getHandler)
    
    
    messagesRoute.get("send", use: sendHandler)
  }
  
//  func createHandler(_ req: Request, message: Message) throws -> Future<Message> {
//    return message.save(on: req)
//  }
//
//  func getAllHandler(_ req: Request) throws -> Future<[Message]> {
//    return Message.query(on: req).all()
//  }
//
//  func getHandler(_ req: Request) throws -> Future<Message> {
//    return try req.parameters.next(Message.self)
//  }
  
  
  func sendHandler(_ req: Request) throws -> Future<Message> {
    
    let itemID: Int = try req.content.syncGet(at: "itemID")
    let date: Date = try req.content.syncGet(at: "date")
    let senderID: String = try req.content.syncGet(at: "donorID")
    let receiverID: String = try req.content.syncGet(at: "receiverID")
    let body: String = try req.content.syncGet(at: "body")
    
    let msg = Message(itemID: itemID, sendDateTime: date, body: body, senderID: senderID, receiverID: receiverID)
    
    return msg.save(on: req)
  }
}
