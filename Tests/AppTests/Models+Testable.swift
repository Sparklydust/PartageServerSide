@testable import App
import FluentPostgreSQL
import Crypto

//MARK: - Create an user for testing purposes
extension User {
  static func create(firstName: String = "Luke", LastName: String = "Skywalker", email: String? = "luke@skywalker.com", password: String = "password", on connection: PostgreSQLConnection) throws -> User {
    let createUserEmail: String
    if let suppliedEmail = email {
      createUserEmail = suppliedEmail
    }
    else {
      createUserEmail = UUID().uuidString
    }
    let cryptedPassword = try BCrypt.hash(password)
    let user = User(firstName: firstName, lastName: LastName, email: createUserEmail, password: cryptedPassword)
    return try user.save(on: connection).wait()
  }
}

//MARK: - Create a donated item for testing purposes
extension DonatedItem {
  static func create(isPicked: Bool = false, selectedType: String = "Food", name: String = "Pasta", pickupDataTime: String = "2019-08-01T22:05:04+02:00", description: String = "Yummy pasta", latitude: Double = 44.93, longitutde: Double = 4.87, donorID: User? = nil, receiverID: String? = "", on connection: PostgreSQLConnection) throws -> DonatedItem {
    var donor = donorID
    if donor == nil {
      donor = try User.create(on: connection)
    }
    
    let donatedItem = DonatedItem(isPicked: isPicked, selectedType: selectedType, name: name, pickUpDateTime: pickupDataTime, description: description, latitude: latitude, longitude: longitutde, donorID: donor!.id!, receiverID: receiverID)
    return try donatedItem.save(on: connection).wait()
  }
}
