import Vapor
import FluentPostgreSQL

final class Message: Codable {
  var id: Int?
  var itemID: Int
  var isReadByReceiver: Bool?
  var sendDateTime: Date
  var body: String
  var senderID: String
  var receiverID: String
  
  init(itemID: Int, isReadByReceiver: Bool? = false, sendDateTime: Date, body: String, senderID: String, receiverID: String) {
    self.itemID = itemID
    self.isReadByReceiver = isReadByReceiver
    self.sendDateTime = sendDateTime
    self.body = body
    self.senderID = senderID
    self.receiverID = receiverID
  }
}

extension Message: PostgreSQLModel {}
extension Message: Migration {}
extension Message: Content {}
extension Message: Parameter {}
