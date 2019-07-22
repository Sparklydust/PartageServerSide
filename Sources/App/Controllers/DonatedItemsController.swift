import Vapor
import Fluent
import Authentication

//MARK: - Donated items routes
struct DonatedItemsController: RouteCollection {
  
  func boot(router: Router) throws {
    let donatedItemsRoutes = router.grouped("api", "donatedItems")
    
    donatedItemsRoutes.get(use: getAllHandler)
    donatedItemsRoutes.get(DonatedItem.parameter, use: getHandler)
    donatedItemsRoutes.get("search", use: searchHandler)
    
    //MARK: - Protect the path for only authenticate user can save a donated item
    let tokenAuthMiddleware = User.tokenAuthMiddleware()
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let tokenAuthGroup = donatedItemsRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
    tokenAuthGroup.post(DonatedItemCreateData.self, use: createHandler)
    tokenAuthGroup.delete(DonatedItem.parameter, use: deleteHandler)
    tokenAuthGroup.put(DonatedItem.parameter, use: updateHandler)
    tokenAuthGroup.get(DonatedItem.parameter, "user", use: getUserHandler)
  }
  
  //MARK: - Create a donated item
  func createHandler(_ req: Request, data: DonatedItemCreateData) throws -> Future<DonatedItem> {
    let user = try req.requireAuthenticated(User.self)
    let donatedItem = try DonatedItem(
      selectedType: data.selectedType,
      name: data.name,
      pickUpDateTime: data.pickUpDateTime,
      description: data.description,
      latitude: data.latitude,
      longitude: data.longitude,
      donorID: user.requireID())
    return donatedItem.save(on: req)
  }
  
  //MARK: - Get all donated items
  func getAllHandler(_ req: Request) throws -> Future<[DonatedItem]> {
    return DonatedItem.query(on: req).all()
  }
  
  //MARK: - Get one donated item
  func getHandler(_ req: Request) throws -> Future<DonatedItem> {
    return try req.parameters.next(DonatedItem.self)
  }
  
  //MARK: - Update one donated item
  func updateHandler(_ req: Request) throws -> Future<DonatedItem> {
    return try flatMap(to: DonatedItem.self, req.parameters.next(DonatedItem.self), req.content.decode(DonatedItemCreateData.self), { (donatedItem, updateDonatedItem) in
      donatedItem.selectedType = updateDonatedItem.selectedType
      donatedItem.name = updateDonatedItem.name
      donatedItem.pickUpDateTime = updateDonatedItem.pickUpDateTime
      donatedItem.description = updateDonatedItem.description
      donatedItem.latitude = updateDonatedItem.latitude
      donatedItem.longitude = updateDonatedItem.longitude
      
      let user = try req.requireAuthenticated(User.self)
      donatedItem.donorID = try user.requireID()
      return donatedItem.save(on: req)
    })
  }
  
  //MARK: - Delete one donated item
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req
      .parameters
      .next(DonatedItem.self)
      .delete(on: req)
      .transform(to: .noContent)
  }
  
  //MARK: - Search for all donated items chosen selected type
  func searchHandler(_ req: Request) throws -> Future<[DonatedItem]> {
    guard let searchTerm = req.query[String.self, at: "term"] else {
      throw Abort(.badRequest)
    }
    return DonatedItem.query(on: req)
      .filter(\.selectedType == searchTerm)
      .all()
  }
  
  //MARK: - Get the donor associated to the item
  func getUserHandler(_ req: Request) throws -> Future<User.Public> {
    return try req
      .parameters.next(DonatedItem.self)
      .flatMap(to: User.Public.self, { (donatedItem) in
        donatedItem.user.get(on: req).convertToPublic()
      })
  }
}

//MARK: - Defines the request data a user has to send to create an item
struct DonatedItemCreateData: Content {
  let selectedType: String
  let name: String
  let pickUpDateTime: String
  let description: String
  let latitude: Double
  let longitude: Double
}
