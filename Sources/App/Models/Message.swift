import Vapor
import FluentPostgreSQL

final class Message: Codable {
  var id: Int?
  var createdBy: User.ID
  var senderID: String
  var recipientID: String
  var date: String
  var isReadBySender: Bool
  var isReadByRecipient: Bool
  
  init(createdBy: User.ID, senderID: String, recipientID: String, date: String, isReadBySender: Bool, isReadByRecipient: Bool) {
    self.createdBy = createdBy
    self.senderID = senderID
    self.recipientID = recipientID
    self.date = date
    self.isReadBySender = isReadBySender
    self.isReadByRecipient = isReadByRecipient
  }
}

extension Message: PostgreSQLModel {}
extension Message: Content {}
extension Message: Parameter {}

//MARK: - Setting up parent and children relationship
extension Message {
  var sender: Parent<Message, User> {
    return parent(\.createdBy)
  }
  
  var chatMessage: Children<Message, ChatMessage> {
    return children(\.messageID)
  }
}

//MARK: - To delete or update an item on cascade
extension Message: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.createdBy, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}
