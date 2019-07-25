import FluentPostgreSQL
import Foundation

final class FavoritedItemsUsersPivot: PostgreSQLUUIDPivot {
  var id: UUID?
  
  var itemFavoritedID: DonatedItem.ID
  var favoritedByUserID: User.ID
  
  typealias Left = DonatedItem
  typealias Right = User
  
  static let leftIDKey: LeftIDKey = \.itemFavoritedID
  static let rightIDKey: RightIDKey = \.favoritedByUserID
  
  init(_ donatedItem: DonatedItem, _ receiver: User) throws {
    self.itemFavoritedID = try donatedItem.requireID()
    self.favoritedByUserID = try receiver.requireID()
  }
}

extension FavoritedItemsUsersPivot: ModifiablePivot {}

extension FavoritedItemsUsersPivot: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.itemFavoritedID, to: \DonatedItem.id, onUpdate: .cascade, onDelete: .cascade)
      builder.reference(from: \.favoritedByUserID, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}
