import Vapor
import FluentPostgreSQL

final class ChatMessage: Codable {
  var id: Int?
  var user: String
  var date: String
  var content: String
  var messageID: Message.ID
  
  init(user: String, date: String, content: String, messageID: Message.ID) {
    self.user = user
    self.date = date
    self.content = content
    self.messageID = messageID
  }
}

extension ChatMessage: PostgreSQLModel {}
extension ChatMessage: Content {}
extension ChatMessage: Parameter {}

//MARK: - Create a foreign key to parent Message
extension ChatMessage {
  var message: Parent<ChatMessage, Message> {
    return parent(\.messageID)
  }
}

//MARK: - Foreign key constraint to delete or update on cascade
extension ChatMessage: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.messageID, to: \Message.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}
