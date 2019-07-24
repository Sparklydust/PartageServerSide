import Vapor
import FluentPostgreSQL

final class Message: Codable {
  var id: Int?
  var isRead: Bool
  var sendDateTime: Date
  var body: [String]
  
  init(isRead: Bool, sendDateTime: Date, body: [String]) {
    self.isRead = isRead
    self.sendDateTime = sendDateTime
    self.body = body
  }
}

extension Message: PostgreSQLModel {}
extension Message: Migration {}
extension Message: Content {}
extension Message: Parameter {}
