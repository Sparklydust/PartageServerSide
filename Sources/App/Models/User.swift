import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
  var id: UUID?
  var firstName: String
  var lastName: String
  var email: String
  
  init(firstName: String, lastName: String, email: String) {
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

extension User {
  var donatedItems: Children<User, DonatedItem> {
    return children(\.donorID)
  }
}
