import Vapor
import FluentPostgreSQL

final class DonatedItem: Codable {
  var id: Int?
  var isPicked: Bool
  var selectedType: String
  var name: String
  var pickUpDateTime: String
  var description: String
  var latitude: Double
  var longitude: Double
  var donorID: User.ID
  var receiverID: String?
  
  init(isPicked: Bool, selectedType: String, name: String, pickUpDateTime: String, description: String, latitude: Double, longitude: Double, donorID: User.ID, receiverID: String? = String()) {
    self.isPicked = isPicked
    self.selectedType = selectedType
    self.name = name
    self.pickUpDateTime = pickUpDateTime
    self.description = description
    self.latitude = latitude
    self.longitude = longitude
    self.donorID = donorID
    self.receiverID = receiverID
  }
}

extension DonatedItem: PostgreSQLModel {}
extension DonatedItem: Content {}
extension DonatedItem: Parameter {}

//MARK: - Setting up parent and sibling relationship 
extension DonatedItem {
  var user: Parent<DonatedItem, User> {
    return parent(\.donorID)
  }
  
  var favoritedByUser: Siblings<DonatedItem, User, FavoritedItemsUsersPivot> {
    return siblings()
  }
}

//MARK: - To delete or update an item on cascade
extension DonatedItem: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.donorID, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}
