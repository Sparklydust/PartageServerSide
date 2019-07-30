import Vapor
import FluentPostgreSQL

final class Message: Codable {
  var id: Int?
  var itemID: Int
  var isReadByDonor: Bool
  var isReadByReceiver: Bool
  var sendDateTime: [Date]
  var body: [String]
  var donorID: String?
  var receiverID: String?
  
  init(itemID: Int, isReadByDonor: Bool, isReadByReceiver: Bool, sendDateTime: [Date], body: [String], donorID: String? = String(), receiverID: String = String()) {
    self.itemID = itemID
    self.isReadByDonor = isReadByDonor
    self.isReadByReceiver = isReadByReceiver
    self.sendDateTime = sendDateTime
    self.body = body
    self.donorID = donorID
    self.receiverID = receiverID
  }
}

extension Message: PostgreSQLModel {}
extension Message: Migration {}
extension Message: Content {}
extension Message: Parameter {}
