import FluentPostgreSQL
import Vapor

final class DeviceTokensController: RouteCollection {
  
  func boot(router: Router) throws {
    let routes = router.grouped("api", "deviceToken")
    routes.post(DeviceToken.self, use: storeDeviceToken)
    routes.delete(String.parameter, use: removeDeviceToken)
  }
  
  //MARK: - To store de device token in the database
  func storeDeviceToken(_ req: Request, token: DeviceToken) throws -> Future<DeviceToken> {
    return token.save(on: req)
  }
  
  //MARK: - To remove the token off the database
  func removeDeviceToken(_ req: Request) throws -> Future<HTTPStatus> {
    let tokenStr = try req.parameters.next(String.self)
    return DeviceToken.query(on: req)
      .filter(\.token == tokenStr)
      .delete()
      .transform(to: .ok)
  }
}
