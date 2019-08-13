import Vapor
import Fluent
import Authentication
import Foundation

struct MessagesController: RouteCollection {
  
  func boot(router: Router) throws {
    let messagesRoute = router.grouped("api", "messages")
    
    //MARK: - Protect the path for only authenticate users use messages
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let tokenAuthGroup = messagesRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    tokenAuthGroup.post(MessageCreateData.self, use: createHandler)
    tokenAuthGroup.get("ofUser", String.parameter, use: getAllOfUserHandler)
    tokenAuthGroup.get(Message.parameter, use: getHandler)
    tokenAuthGroup.put(Message.parameter, use: updateHandler)
    tokenAuthGroup.delete(Message.parameter, use: deleteHandler)
    tokenAuthGroup.get(Message.parameter, "chatMessages", use: getAllChatMessagesHandler)
  }
  
  //MARK: - Create a new message converstation between two users
  func createHandler(_ req: Request, data: MessageCreateData) throws -> Future<Message> {
    let user = try req.requireAuthenticated(User.self)
    let message = try Message(
      createdBy: user.requireID(),
      senderID: data.senderID,
      recipientID: data.recipientID,
      date: data.date,
      isReadBySender: data.isReadBySender,
      isReadByRecipient: data.isReadByRecipient
    )
    return message.save(on: req)
  }
  
  //MARK: - Filter and get messages with userID on senderID or recipientID
  func getAllOfUserHandler(_ req: Request) throws -> Future<[Message]> {
    let userID = try req.parameters.next(String.self)
    return Message.query(on: req).group(.or, closure: { (or) in
      or.filter(\Message.senderID == userID)
      or.filter(\Message.recipientID == userID)
    }).sort(\Message.date, .descending)
      .all()
  }

  //MARK: - Get one message with its id
  func getHandler(_ req: Request) throws -> Future<Message> {
    return try req.parameters.next(Message.self)
  }
  
  //MARK: - Update a message
  func updateHandler(_ req: Request) throws -> Future<Message> {
    return try flatMap(to: Message.self, req.parameters.next(Message.self), req.content.decode(MessageCreateData.self), { (message, updatedMessage) in
      message.senderID = updatedMessage.senderID
      message.recipientID = updatedMessage.recipientID
      message.date = updatedMessage.date
      message.isReadBySender = updatedMessage.isReadBySender
      message.isReadByRecipient = updatedMessage.isReadByRecipient
      
      return message.save(on: req)
    })
  }
  
  //MARK: - Delete Message
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req
    .parameters
    .next(Message.self)
    .delete(on: req)
    .transform(to: .noContent)
  }
  
  //MARK: - Get all chat messages parent/child relation objects
  func getAllChatMessagesHandler(_ req: Request) throws -> Future<[ChatMessage]> {
    return try req
    .parameters.next(Message.self)
      .flatMap(to: [ChatMessage].self, { (message) in
        try message.chatMessage.query(on: req)
        .sort(\ChatMessage.id, .ascending)
        .all()
      })
  }
}

//MARK: - Request data a user send to create a message
struct MessageCreateData: Content {
  var senderID: String
  var recipientID: String
  var date: String
  var isReadBySender: Bool
  var isReadByRecipient: Bool
}
