import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
  router.get("hello") { (req) -> String in
    return "Hello Partage and welcome to your own server side using Swift!"
  }
}
