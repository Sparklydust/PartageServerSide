import Vapor
import Crypto
import Authentication
import SendGrid
import S3

struct UsersController: RouteCollection {
  
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "users")
    
    usersRoute.post(User.self, use: createHandler)
    
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    
    basicAuthGroup.post("login", use: loginHandler)
    basicAuthGroup.delete("delete", User.parameter, use: deleteHandler)
    basicAuthGroup.get(User.parameter, "donatedItems", use: getDonatedItemsHandler)
    basicAuthGroup.get(User.parameter, use: getHandler)
    basicAuthGroup.get("myAccount", User.parameter, use: getNonPublicUserHandler)
    basicAuthGroup.get(use: getAllHandler)
    basicAuthGroup.get(User.parameter, "itemsFavorited", use: getFavoritedItemsHandler)
    basicAuthGroup.put("editAccount", User.parameter, use: updateUserHandler)
    basicAuthGroup.put("editAccountAndPassord", User.parameter, use: updateUserAndPasswordHandler)
  }
  
  //MARK: - Create a new user
  func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
    user.password = try BCrypt.hash(user.password)
    return user.save(on: req).convertToPublic()
  }
  
  //MASRK: - Get all user in public
  func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
    return User.query(on: req).decode(data: User.Public.self).all()
  }
  
  //MARK: - Get one user in public
  func getHandler(_ req: Request) throws -> Future<User.Public> {
    return try req.parameters.next(User.self).convertToPublic()
  }
  
  //MARK: - Get full user
  func getNonPublicUserHandler(_ req: Request) throws -> Future<User> {
    return try req.parameters.next(User.self)
  }
  
  //MARK: - Get all items associated to an user
  func getDonatedItemsHandler(_ req: Request) throws -> Future<[DonatedItem]> {
    return try req
      .parameters.next(User.self)
      .flatMap(to: [DonatedItem].self, { (user) in
        try user.donatedItems.query(on: req).all()
      })
  }
  
  //MARK: - User login
  func loginHandler(_ req: Request) throws -> Future<Token> {
    let user = try req.requireAuthenticated(User.self)
    let token = try Token.generate(for: user)
    return token.save(on: req)
  }
  
  //MARK: - Delete an user
  func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
    return try req
      .parameters
      .next(User.self)
      .delete(on: req)
      .transform(to: .noContent)
  }
  
  //MARK: - Get all items an user favorited
  func getFavoritedItemsHandler(_ req: Request) throws -> Future<[DonatedItem]> {
    return try req.parameters.next(User.self)
      .flatMap(to: [DonatedItem].self, { (user) in
        try user.itemFavorited.query(on: req).all()
      })
  }
  
  //MARK: - Update an user info without password
  func updateUserHandler(_ req: Request) throws -> Future<User> {
    return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(UserCreateData.self), { (user, updatedUser) in
      user.firstName = updatedUser.firstName
      user.lastName = updatedUser.lastName
      user.email = updatedUser.email
      
      return user.save(on: req)
    })
  }
  
  //MARK: - Update user info and password
  func updateUserAndPasswordHandler(_ req: Request) throws -> Future<User> {
    return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(UserCreatePasswordData.self), { (user, updatedUser) in
      user.firstName = updatedUser.firstName
      user.lastName = updatedUser.lastName
      user.email = updatedUser.email
      user.password = try BCrypt.hash(updatedUser.password)
      
      return user.save(on: req)
    })
  }
}

//MARK: - Defines the request data a user has to send to update his attributes
struct UserCreateData: Content {
  var firstName: String
  var lastName: String
  var email: String
}

//MARK: - Defines the request data a user has to send to update his attributes and password
struct UserCreatePasswordData: Content {
  var firstName: String
  var lastName: String
  var email: String
  var password: String
}
