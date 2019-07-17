import Vapor
import FluentPostgreSQL

final class Message: Codable {
  var id: Int?
  var isRead: Bool
  var sendDateTime: String
  var body: String
  
  init(isRead: Bool, sendDateTime: String, body: String) {
    self.isRead = isRead
    self.sendDateTime = sendDateTime
    self.body = body
  }
}

extension Message: PostgreSQLModel {}
extension Message: Migration {}
extension Message: Content {}
extension Message: Parameter {}
