@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
  let usersFirstName = "Alice"
  let usersLastName = "Wonderland"
  let usersEmail = "alice@wonderland.com"
  let usersPassword = "password"
  let usersURI = "api/users/"
  var app: Application!
  var conn: PostgreSQLConnection!
  
  //MARK: - Revert the database, generates an Application for the test and create a connection to the database
  override func setUp() {
    try! Application.reset()
    app = try! Application.testable()
    conn = try! app.newConnection(to: .psql).wait()
  }
  
  //MARK: - Close the connection to the database and shut the application down
  override func tearDown() {
    conn.close()
    try? app.syncShutdownGracefully()
  }
  
  func testUsersCanBeRetrievedFromAPI() throws {
    let user = try User.create(firstName: usersFirstName, LastName: usersLastName, email: usersEmail, password: usersPassword, on: conn)
    _ = try User.create(on: conn)
    
    let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)
    
    XCTAssertEqual(users.count, 3)
    XCTAssertEqual(users[1].firstName, usersFirstName)
    XCTAssertEqual(users[1].id, user.id)
  }
  
  func testUserCanBeSavedWithAPI() throws {
    let user = User(firstName: usersFirstName, lastName: usersLastName, email: usersEmail, password: usersPassword)
    
    let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-Type": "application/json"], data: user, decodeTo: User.Public.self, loggedInRequest: true)
    
    XCTAssertEqual(receivedUser.firstName, usersFirstName)
    XCTAssertNotNil(receivedUser.id)
    
    let users = try app.getResponse(to: usersURI, decodeTo: [User.Public].self)
    
    XCTAssertEqual(users.count, 2)
    XCTAssertEqual(users[1].firstName, usersFirstName)
    XCTAssertEqual(users[1].id, receivedUser.id)
  }
  
  func testGettingASingleUserFromTheAPI() throws {
    let user = try User.create(firstName: usersFirstName, LastName: usersLastName, email: usersEmail, password: usersPassword, on: conn)
    
    let receivedUser = try app.getResponse(to: "\(usersURI)\(user.id!)", decodeTo: User.Public.self)
    
    XCTAssertEqual(receivedUser.firstName, usersFirstName)
    XCTAssertEqual(receivedUser.id, user.id)
  }
  
  func testGettingAUserDonatedItemFromTheAPI() throws {
    let user = try User.create(on: conn)
    
    let itemIsPicked = false
    let itemSelectedType = "Vêtement"
    let itemName = "T-shirt Volcom"
    let itemPickUpDateTime = "2019-08-05T00:45:41+02:00"
    let itemDescription = "Volcom t-shirt size M"
    let itemLatitude = 44.936685063347653
    let itemLongitude = 4.8753775960867642
    let itemReceiverID = ""
    
    let donatedItem1 = try DonatedItem.create(isPicked: itemIsPicked, selectedType: itemSelectedType, name: itemName, pickupDataTime: itemPickUpDateTime, description: itemDescription, latitude: itemLatitude, longitutde: itemLongitude, donorID: user, receiverID: itemReceiverID, on: conn)
    _ = try DonatedItem.create(isPicked: true, selectedType: "Nourriture", name: "Pizza", pickupDataTime: "2019-08-05T00:45:41+02:00", description: "Yummy pizza", latitude: 44.93, longitutde: 4.87, donorID: user, receiverID: "E7E30595-6DD0-4767-BB25-9139EB34518C", on: conn)
    
    let donatedItems = try app.getResponse(to: "\(usersURI)\(user.id!)/donatedItems", decodeTo: [DonatedItem].self)
    
    XCTAssertEqual(donatedItems.count, 2)
    XCTAssertEqual(donatedItems[0].id, donatedItem1.id)
    XCTAssertEqual(donatedItems[0].description, itemDescription)
    XCTAssertEqual(donatedItems[0].name, itemName)
  }
}
