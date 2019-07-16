import Vapor
import FluentPostgreSQL

final class DonatedItem: Codable {
  var id: Int?
}

extension DonatedItem: PostgreSQLModel {}
extension DonatedItem: Migration {}
extension DonatedItem: Content {}
