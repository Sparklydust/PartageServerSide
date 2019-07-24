import Vapor
import FluentPostgreSQL

final class MessageUsersPivot: Codable {
  var id: Int?
  var donorID: UUID
  var receiverID: UUID
  var messageID: Int
  
  init(donorID: UUID, receiverID: UUID, messageID: Int) {
    self.donorID = donorID
    self.receiverID = receiverID
    self.messageID = messageID
  }
}

extension MessageUsersPivot: PostgreSQLModel {}
extension MessageUsersPivot: Content {}
extension MessageUsersPivot: Parameter {}

extension MessageUsersPivot: Migration {}
