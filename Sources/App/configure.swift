import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  // Register providers first
  try services.register(FluentPostgreSQLProvider())
  try services.register(AuthenticationProvider())
  
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
  migrations.add(model: ItemsUserPivot.self, database: .psql)
  
  migrations.add(migration: AdminUser.self, database: .psql)
  
  services.register(migrations)
}
