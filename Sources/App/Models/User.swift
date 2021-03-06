import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
  var id: UUID?
  var firstName: String
  var lastName: String
  var email: String
  var password: String
  var profilePicture: String?
  
  init(firstName: String, lastName: String, email: String, password: String, profilePicture: String? = nil) {
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
    self.password = password
    self.profilePicture = profilePicture
  }
  
  final class Public: Codable {
    var id: UUID?
    var firstName: String
    
    init(id: UUID?, firstName: String) {
      self.id = id
      self.firstName = firstName
    }
  }
}

extension User: PostgreSQLUUIDModel {}
extension User: Content {}
extension User: Parameter {}

extension User.Public: Content {}

//MARK: - Setting up children and sibling relationship
extension User {
  var donatedItems: Children<User, DonatedItem> {
    return children(\.donorID)
  }
  
  var messages: Children<User, Message> {
    return children(\.createdBy)
  }
  
  var itemFavorited: Siblings<User, DonatedItem, FavoritedItemsUsersPivot> {
    return siblings()
  }
}

//MARK: - Creating an unique email in the database
extension User: Migration {
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    return Database.create(self, on: connection, closure: { (builder) in
      try addProperties(to: builder)
      builder.unique(on: \.email)
    })
  }
}

//MARK: - Convert User to a public mode
extension User {
  func convertToPublic() -> User.Public {
    return User.Public(id: id, firstName: firstName)
  }
}

//MARK: - Convert User to a public mode
extension Future where T: User {
  func convertToPublic() -> Future<User.Public> {
    return self.map(to: User.Public.self, { (user) in
      return user.convertToPublic()
    })
  }
}

//MARK: - Used to authenticate the user
extension User: BasicAuthenticatable {
  static let usernameKey: UsernameKey = \User.email
  static let passwordKey: PasswordKey = \User.password
}

//MARK: - Token authentication
extension User: TokenAuthenticatable {
  typealias TokenType = Token 
}

//MARK: - Creation of the admin user
struct AdminUser: Migration {
  typealias Database = PostgreSQLDatabase
  
  static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    let password = try? BCrypt.hash("t44jsbz77YdvnyDiNjR6qvURX")
    guard let hashedPassword = password else {
      fatalError("Failed to create admin user")
    }
    let user = User(firstName: "admin", lastName: "admin", email: "roland.sound@live.fr", password: hashedPassword)
    return user.save(on: connection).transform(to: ())
  }
  
  static func revert(on connection: PostgreSQLConnection) -> Future<Void> {
    return .done(on: connection)
  }
}
