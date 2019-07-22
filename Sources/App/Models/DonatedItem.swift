import Vapor
import FluentPostgreSQL

final class DonatedItem: Codable {
  var id: Int?
  var selectedType: String
  var name: String
  var pickUpDateTime: String
  var description: String
  var latitude: Double
  var longitude: Double
  var donorID: User.ID
  
  init(selectedType: String, name: String, pickUpDateTime: String, description: String, latitude: Double, longitude: Double, donorID: User.ID) {
    self.selectedType = selectedType
    self.name = name
    self.pickUpDateTime = pickUpDateTime
    self.description = description
    self.latitude = latitude
    self.longitude = longitude
    self.donorID = donorID
  }
}

extension DonatedItem: PostgreSQLModel {}
extension DonatedItem: Content {}
extension DonatedItem: Parameter {}

extension DonatedItem {
  var user: Parent<DonatedItem, User> {
    return parent(\.donorID)
  }
}

extension DonatedItem: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.donorID, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}
