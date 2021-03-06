import FluentPostgreSQL
import Vapor
import Leaf
import Authentication
import S3
import SendGrid

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
  // Register providers first
  try services.register(FluentPostgreSQLProvider())
  try services.register(LeafProvider())
  try services.register(AuthenticationProvider())
  try services.register(SendGridProvider())
  try services.register(s3: S3Signer.Config(accessKey: "AKIAYSE6L7UH7PQLWIFZ",
                                            secretKey: "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",
                                            region: .euWest3), defaultBucket: "s3partage")
  
  // Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
  
  // Register routes to the web socket server
  let webSockets = NIOWebSocketServer.default()
  try socketRoutes(webSockets)
  services.register(webSockets, as: WebSocketServer.self)
  
  // Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  services.register(middlewares)
  
  // Configure a database
  var databases = DatabasesConfig()
  
  let databaseConfig: PostgreSQLDatabaseConfig
  
  if let url = Environment.get("DATABASE_URL") {
    databaseConfig = PostgreSQLDatabaseConfig(url: url)!
  }
  else if let url = Environment.get("DB_POSTGRESQL") {
    databaseConfig = PostgreSQLDatabaseConfig(url: url)!
  }
  else {
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "Sparklydust"
    let password = Environment.get("DATABASE_PASSWORD") ?? "E87Lp6y3eMAGbkTBKt9PGwsAi"
    let databasePort: Int
    let databaseName: String
    
    if (env == .testing) {
      databaseName = "PartageServerSide-test"
      if let testPort = Environment.get("DATABASE_PORT") {
        databasePort = Int(testPort) ?? 5433
      }
      else {
        databasePort = 5433
      }
    }
    else {
      databaseName = Environment.get("DATABASE_DB") ?? "PartageServerSide"
      databasePort = 5432
    }
    
    // Run the server locally but connected over my local network
    var serverConfig = NIOServerConfig.default()
    serverConfig.hostname = "192.168.1.61"
    services.register(serverConfig)
    
    databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname,
                                              port: databasePort,
                                              username: username,
                                              database: databaseName,
                                              password: password)
  }
  
  let database = PostgreSQLDatabase(config: databaseConfig)
  databases.add(database: database, as: .psql)
  services.register(databases)
  
  // Configure migrations
  var migrations = MigrationConfig()
  
  migrations.add(model: User.self, database: .psql)
  migrations.add(model: DonatedItem.self, database: .psql)
  migrations.add(model: Message.self, database: .psql)
  migrations.add(model: ChatMessage.self, database: .psql)
  migrations.add(model: Token.self, database: .psql)
  migrations.add(model: DeviceToken.self, database: .psql)
  migrations.add(model: FavoritedItemsUsersPivot.self, database: .psql)
  migrations.add(model: ResetPasswordToken.self, database: .psql)
  migrations.add(migration: AdminUser.self, database: .psql)
  services.register(migrations)
  
  config.prefer(LeafRenderer.self, for: ViewRenderer.self)
  
  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
  
  // Configure SendGrid email sender provider service
  let sendGridConfig = SendGridConfig(
    apiKey: "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")
  services.register(sendGridConfig)
}
