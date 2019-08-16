import FluentPostgreSQL
import Vapor

//MARK: - DeviceToken is for Apple push notifications services
final class DeviceToken: PostgreSQLUUIDModel {
  var id: UUID?
  let token: String
  let debug: Bool
  
  init(token: String, debug: Bool) {
    self.token = token
    self.debug = debug
  }
}

extension DeviceToken: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection) { builder in
      try addProperties(to: builder)
      builder.unique(on: \.token)
    }
  }
}

extension DeviceToken: Content {}
extension DeviceToken: Parameter {}
