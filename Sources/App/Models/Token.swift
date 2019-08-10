import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
  var id: UUID?
  var token: String
  var userID: User.ID
  
  init(token: String, userID: User.ID) {
    self.token = token
    self.userID = userID
  }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Content {}

//MARK: - To delete or update an item on cascade
extension Token: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.reference(from: \.userID, to: \User.id, onUpdate: .cascade, onDelete: .cascade)
    })
  }
}

//MARK: - To generate a token for an user
extension Token {
  static func generate(for user: User) throws -> Token {
    let random = try CryptoRandom().generateData(count: 16)
    return try Token(token: random.base64EncodedString(), userID: user.requireID())
  }
}

//MARK: - Define the userID ey on token
extension Token: Authentication.Token {
  static let userIDKey: UserIDKey = \Token.userID
  typealias UserType = User
}

//MARK: - To user token with bearer authenticatable
extension Token: BearerAuthenticatable {
  static let tokenKey: TokenKey = \Token.token
}
