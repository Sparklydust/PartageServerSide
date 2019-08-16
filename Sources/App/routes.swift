import Vapor
import Fluent

// Register application's routes here.
public func routes(_ router: Router) throws {
  
  let donatedItemsController = DonatedItemsController()
  try router.register(collection: donatedItemsController)
  
  let usersController = UsersController()
  try router.register(collection: usersController)
  
  let messagesController = MessagesController()
  try router.register(collection: messagesController)
  
  let chatMessagesController = ChatMessagesController()
  try router.register(collection: chatMessagesController)
  
  let deviceTokensController = DeviceTokensController()
  try router.register(collection: deviceTokensController)
  
  let websiteController = WebsiteController()
  try router.register(collection: websiteController)
}

// Register application's web socket routes here.
public func socketRoutes(_ webSockets: NIOWebSocketServer) throws {
  
  webSockets.get("echo") { (ws, req) in
    print("ws connected")
    
    ws.onText({ (ws, text) in
      print("ws received: \(text)")
      ws.send("echo - \(text)")
    })
  }
}
