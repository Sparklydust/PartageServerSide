import FluentPostgreSQL
import Foundation

final class ItemsUserPivot: PostgreSQLUUIDPivot {
  var id: UUID?
  
  var donatedItemID: DonatedItem.ID
  var userReceiverID: User.ID
  
  typealias Left = DonatedItem
  typealias Right = User
  
  static let leftIDKey: LeftIDKey = \.donatedItemID
  static let rightIDKey: RightIDKey = \.userReceiverID
  
  init(_ donatedItem: DonatedItem, _ receiver: User) throws {
    self.donatedItemID = try donatedItem.requireID()
    self.userReceiverID = try receiver.requireID()
  }
}

extension ItemsUserPivot: ModifiablePivot {}

extension ItemsUserPivot: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.donatedItemID, to: \DonatedItem.id, onUpdate: .cascade, onDelete: .cascade)
      builder.reference(from: \.userReceiverID, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}
