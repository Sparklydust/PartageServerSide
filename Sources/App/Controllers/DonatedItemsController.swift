import Vapor
import Fluent

//MARK: - Donated items routes
struct DonatedItemsController: RouteCollection {
  
  func boot(router: Router) throws {
    let donatedItemsRoutes = router.grouped("api", "donatedItems")
    
    donatedItemsRoutes.post(DonatedItem.self, use: createHandler)
    donatedItemsRoutes.get(use: getAllHandler)
    donatedItemsRoutes.get(DonatedItem.parameter, use: getHandler)
    donatedItemsRoutes.put(DonatedItem.parameter, use: updateHandler)
    donatedItemsRoutes.delete(DonatedItem.parameter, use: deleteHandler)
    donatedItemsRoutes.get("search", use: searchHandler)
    donatedItemsRoutes.get(DonatedItem.parameter, "user", use: getUserHandler)
  }
  
  //MARK: - Create a donated item
  func createHandler(_ req: Request, donatedItem: DonatedItem) throws -> Future<DonatedItem> {
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
    return try flatMap(to: DonatedItem.self, req.parameters.next(DonatedItem.self), req.content.decode(DonatedItem.self), { (donatedItem, updateDonatedItem) in
      donatedItem.selectedType = updateDonatedItem.selectedType
      donatedItem.name = updateDonatedItem.name
      donatedItem.pickUpDateTime = updateDonatedItem.pickUpDateTime
      donatedItem.description = updateDonatedItem.description
      donatedItem.latitude = updateDonatedItem.latitude
      donatedItem.longitude = updateDonatedItem.longitude
      donatedItem.donorID = updateDonatedItem.donorID
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
  func getUserHandler(_ req: Request) throws -> Future<User> {
    return try req
    .parameters.next(DonatedItem.self)
      .flatMap(to: User.self, { (donatedItem) in
        donatedItem.user.get(on: req)
      })
  }
}
