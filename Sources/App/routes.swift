import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  
  let donatedItemsController = DonatedItemsController()
  try router.register(collection: donatedItemsController)
  
  let usersController = UsersController()
  try router.register(collection: usersController)
  
  let messagesController = MessagesController()
  try router.register(collection: messagesController)
  
  let websiteController = WebsiteController()
  try router.register(collection: websiteController)
}
