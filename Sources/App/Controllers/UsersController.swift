import Vapor
import Crypto

struct UsersController: RouteCollection {
  
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "users")
    
    usersRoute.post(User.self, use: createHandler)
    usersRoute.get(use: getAllHandler)
    usersRoute.get(User.parameter, use: getHandler)
    usersRoute.get(User.parameter, "donatedItems", use: getDonatedItemsHandler)
    
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)
  }
  
  func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
    user.password = try BCrypt.hash(user.password)
    return user.save(on: req).convertToPublic()
  }
  
  func getAllHandler(_ req: Request) throws -> Future<[User.Public]> {
    return User.query(on: req).decode(data: User.Public.self).all()
  }
  
  func getHandler(_ req: Request) throws -> Future<User.Public> {
    return try req.parameters.next(User.self).convertToPublic()
  }
  
  func getDonatedItemsHandler(_ req: Request) throws -> Future<[DonatedItem]> {
    return try req
    .parameters.next(User.self)
      .flatMap(to: [DonatedItem].self, { (user) in
        try user.donatedItems.query(on: req).all()
      })
  }
  
  func loginHandler(_ req: Request) throws -> Future<Token> {
    let user = try req.requireAuthenticated(User.self)
    let token = try Token.generate(for: user)
    return token.save(on: req)
  }
}
