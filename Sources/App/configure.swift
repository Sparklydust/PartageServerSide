import FluentPostgreSQL
import Vapor
import Leaf
import Authentication
import SendGrid

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  // Register providers first
  try services.register(FluentPostgreSQLProvider())
  try services.register(LeafProvider())
  try services.register(AuthenticationProvider())
  try services.register(SendGridProvider())
  
  // Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
  
  // Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  services.register(middlewares)
  
  // Configure a database
  var databases = DatabasesConfig()
  let databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                username: "Sparklydust",
                                                database: "PartageServerSide",
                                                password: "E87Lp6y3eMAGbkTBKt9PGwsAi"
  )
  let database = PostgreSQLDatabase(config: databaseConfig)
  databases.add(database: database, as: .psql)
  services.register(databases)
  
  // Configure migrations
  var migrations = MigrationConfig()
  
  migrations.add(model: User.self, database: .psql)
  migrations.add(model: DonatedItem.self, database: .psql)
  migrations.add(model: Message.self, database: .psql)
  migrations.add(model: Token.self, database: .psql)
  migrations.add(model: FavoritedItemsUsersPivot.self, database: .psql)
  migrations.add(model: ResetPasswordToken.self, database: .psql)
  migrations.add(migration: AdminUser.self, database: .psql)
  services.register(migrations)
  
  config.prefer(LeafRenderer.self, for: ViewRenderer.self)
  
//  // Configure SendGrid email sender provider service
//  guard let sendGridAPIKey = Environment.get("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") else {
//    fatalError("No SendGrid API Key specified")
//  }
//  let sendGridConfig = SendGridConfig(apiKey: sendGridAPIKey)
//  services.register(sendGridConfig)
}
