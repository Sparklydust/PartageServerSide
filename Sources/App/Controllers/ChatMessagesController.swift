import Vapor
import Fluent
import Authentication

struct ChatMessagesController: RouteCollection {
  
  func boot(router: Router) throws {
    let chatMessageRoute = router.grouped("api", "chatMessages")
    
    //MARK: - Protect the path for only authenticate users can use a chat message
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let tokenAuthGroup = chatMessageRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    
    tokenAuthGroup.post(ChatMessageCreateData.self, use: createHandler)
    tokenAuthGroup.get(ChatMessage.parameter, "parentMessage", use: getMessageHandler)
  }
  
  //MARK: - Create a chat message
  func createHandler(_ req: Request, data: ChatMessageCreateData) throws -> Future<ChatMessage> {
    let chatMessage = ChatMessage(
      user: data.user,
      date: data.date,
      content: data.content,
      messageID: data.messageID
    )
    return chatMessage.save(on: req)
  }
  
  //MARK: - Get the parent Message associated to a chat message
  func getMessageHandler(_ req: Request) throws -> Future<Message> {
    return try req
    .parameters.next(ChatMessage.self)
      .flatMap(to: Message.self, { (chatMessage) in
        chatMessage.message.get(on: req)
      })
  }
}

//MARK: - Defines the request data a user has to send to create a chat message
struct ChatMessageCreateData: Content {
  let user: String
  let date: String
  let content: String
  let messageID: Int
}
